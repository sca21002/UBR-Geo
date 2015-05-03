#!/usr/bin/env perl
use utf8;
use Path::Tiny;
use FindBin qw($Bin);
use lib path($Bin)->parent(2)->child('lib')->stringify,
        path($Bin)->parent(3)->child(qw(Remedi lib))->stringify;
use Data::Dumper;
use Modern::Perl;
use Carp;
use Capture::Tiny ':all';
use Getopt::Long;
use Log::Log4perl qw(:easy);
use Remedi::Imagefile;
use UBR::Geo::GCP::FromFile;
use English qw( -no_match_vars );   # Avoids regex performance penalty
use Pod::Usage;

my ($gcp_dir, $tiff_src, $tiff_dst, $srid, $opt_help, $opt_man); 

GetOptions (
    "gcp_dir=s"   => \$gcp_dir,
    "tiff_src=s"  => \$tiff_src,
    "tiff_dst=s"  => \$tiff_dst,
    "srid=s"       => \$srid,
    'help!'       => \$opt_help,
    'man!'        => \$opt_man,
) or pod2usage( "Try '$PROGRAM_NAME --help' for more information." );

pod2usage( -verbose => 1 ) if $opt_help;
pod2usage( -verbose => 2 ) if $opt_man;

pod2usage( -verbose => 1 ) unless $gcp_dir && $tiff_src && $tiff_dst;

my $logfile = path($Bin)->parent(1)->child('georeference.log');

### Logdatei initialisieren
Log::Log4perl->easy_init(
    { level   => $DEBUG,
      file    => ">" . $logfile,
    },
    { level   => $TRACE,
      file    => 'STDOUT',
    },
);

$gcp_dir  = path($gcp_dir);
$tiff_src = path($tiff_src);
$tiff_dst = path($tiff_dst);
$srid   ||= 'EPSG:3857'; 


INFO('Groundcontrolpoint dir: ' . $gcp_dir);
INFO('TIFF source dir:        ' . $tiff_src);
INFO('TIFF destintation dir:  ' . $tiff_dst);
INFO('Projection:             ' . $srid);

LOGCROAK("Directory of groundcontrolpoints doesn't exist")
    unless $gcp_dir->is_dir;
LOGCROAK("Directory of TIFF source files doesn't exist")
    unless $tiff_src->is_dir;
$tiff_dst->mkpath() unless $tiff_dst->is_dir;

my @gcp_files = path($gcp_dir)->children( qr/\.(.{3})\.points$/ );

INFO(scalar @gcp_files, " groundcontrolpoint files found");

foreach my $gcp_file (@gcp_files) {
    INFO("Working  $gcp_file");
    my $gcp = UBR::Geo::GCP::FromFile->new( file => $gcp_file, srid => $srid );
    write_gcps($gcp);
}

sub write_gcps {
    my $gcp = shift;

    my $tiff_basename = $gcp->filestem . '.tif'; 
    INFO("File name: $tiff_basename");
    my $tiff_file       = Remedi::Imagefile->new(
        file =>	path($tiff_src, $tiff_basename),
        regex_filestem_prefix => qr/ubr\d{5}/,
        regex_filestem_var => qr/_\d{1,5}/,
        size_class_border => 100,
        library_union_id => 'bvb',
        isil => 'DE-355',  
    );

    # gdal_translate removes icc profiles (sometimes?)

    INFO('ICC profile: ', $tiff_file->icc_profile || 'no icc profile');
    my $icc_profile;
    if ($tiff_file->icc_profile) {
        my $cmd = 'exiftool';
        my @options = (
            '-icc_profile',
            '-b',
            #    '-w icc',
            $tiff_file->stringify,
        );
        INFO("Cmd: exiftool ", join " ",@options);
        my ($stdout, $stderr, $exit) = capture {
            system($cmd, @options);
        };    
        INFO("Error: $stderr") if $stderr;
        INFO("Exit code: $exit") if $exit;
        
        my $unlink = 1;
        $icc_profile = Path::Tiny->tempfile(
            UNLINK => $unlink, SUFFIX => '.icc'
        ); 

        $icc_profile->spew_raw($stdout);
        INFO("ICC profile saved in $icc_profile");
    }

    my $tiff_out_path     = path($tiff_dst, $tiff_basename);
    
    my @coords = @{$gcp->gcps_as_href};
    
    my $cmd =  'gdal_translate';
    
    my @options = (
        -of   => 'GTiff',
        -a_srs => $srid, 
    ); 
    
    foreach my $coord (@coords) {
        push @options, '-gcp';
        push @options, 
            sprintf("%.6g", $coord->{pixel}),
            sprintf("%.6g", $coord->{line}),
            sprintf("%.6g", $coord->{x}   ),
            sprintf("%.6g", $coord->{y}   ),
        ;
    }
    INFO(join ' ', $cmd, @options);
    
    my ($stdout, $stderr, $exit) = tee {
        system($cmd, @options, $tiff_file->stringify, $tiff_out_path->stringify);
    };
    #INFO($stdout);
    #INFO("Error: $stderr") if $stderr;
    my $tiff_out = Remedi::Imagefile->new(
        file => $tiff_out_path,
        regex_filestem_prefix => qr/ubr\d{5}/,
        regex_filestem_var => qr/_\d{1,5}/,
        size_class_border => 100,
        library_union_id => 'bvb',
        isil => 'DE-355',  
    );
    if ($icc_profile) { 
       INFO('ICC profile: ', $tiff_out->icc_profile || 'no icc profile');
       INFO('Warn: ICC profile was kicked out by gdal_translate'); 
       unless ($tiff_out->icc_profile) {
           my $cmd = 'exiftool';
           my @options = (
               '-icc_profile<=' . $icc_profile,
               $tiff_out_path,
           );
           INFO("Cmd exiftool: ", join ' ', @options);
           my ($stdout, $stderr, $exit) = capture {
               system($cmd, @options);
           };
           INFO("ICC profile is restored back to image file");
       }
    }
}

=encoding utf-8

=head1 NAME
 
georeference.pl - Add georeferencing data to TIFF files   

=head1 SYNOPSIS

georeference.pl [options]  

 Options:
   --help         display this help and exit
   --man          display extensive help

   --gcp_dir      directory of groundcontrolpoint files
   --tiff_src     directory of TIFF source files
   --tiff_dst     directory of TIFF destination files
   --srid         spatial reference identifier 
                  default: EPSG:3857
 Examples:
   georeference.pl --gcp_dir UBR-Geo/gcp/ubr15411 --tiff_src ubr15411/mst/tif --tiff_dst ubr15411/geo  
   georeference.pl --help
   georeference.pl --man 
   

=head1 DESCRIPTION

Add georeferencing data to TIFF files   

Maps georeferenced with QGIS and georef data are stored as groundcontrol 
points in text files. This files are read and the georeferencing data are 
add to the TIFF headers of archive TIFF files according to the GeoTIFF 
standard.

=head1 AUTHOR

Albert Schröder <albert.schroeder@ur.de>

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
