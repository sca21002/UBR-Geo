#!/usr/bin/env perl
use utf8;
use Path::Tiny;
use FindBin qw($Bin);
use lib path($Bin)->parent(3)->child(qw(Remedi lib))->stringify;
use Data::Dumper;
use Modern::Perl;
use Carp;
use Capture::Tiny ':all';
use Getopt::Long;
use Log::Log4perl qw(:easy);
use Remedi::Imagefile;

my @header_expected = ( qw(mapX mapY pixelX pixelY enable) );

my $gcp_dir;
my $tiff_src;
my $tiff_dst;
my $srs;

GetOptions (
    "gcp_dir=s"   => \$gcp_dir,
    "tiff_src=s"  => \$tiff_src,
    "tiff_dst=s"  => \$tiff_dst,
    "srs=s"       => \$srs,
) or die("Error in command line arguments\n");

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
$srs    ||= 'EPSG:3857'; 


INFO('Groundcontrolpoint dir: ' . $gcp_dir);
INFO('TIFF source dir:        ' . $tiff_src);
INFO('TIFF destintation dir:  ' . $tiff_dst);
INFO('Projection:             ' . $srs);

LOGCROAK("Directory of groundcontrolpoints doesn't exist")
    unless $gcp_dir->is_dir;
LOGCROAK("Directory of TIFF source files doesn't exist")
    unless $tiff_src->is_dir;
$tiff_dst->mkpath() unless $tiff_dst->is_dir;

my @gcp_files = path($gcp_dir)->children( qr/\.tif\.points$/ );

INFO(scalar @gcp_files, " groundcontrolpoint files found");

foreach my $gcp_file (@gcp_files) {
    INFO("Working  $gcp_file");
    write_gcps($gcp_file);
}

sub write_gcps {
    my $gcp_file = shift;

    my ($tiff_basename) = $gcp_file->basename =~ qr/(.*)\.points$/; 
    my $tiff_file       = Remedi::Imagefile->new(
        file =>	path($tiff_src, $tiff_basename),
        regex_filestem_prefix => qr/ubr\d{5}/,
        regex_filestem_var => qr/_\d{1,5}/,
        size_class_border => 100,
        library_union_id => 'bvb',
        isil => 'DE-355',  
    );
    INFO('ICC profile: ', $tiff_file->icc_profile || 'no icc profile');
    my $icc_profile;
    if ($tiff_file->icc_profile) {
        $icc_profile = Path::Tiny->tempfile(SUFFIX => '.icc');
        my $cmd = 'exiftool';
        my @options = (
            '-icc_profile',
            '-b',
            $tiff_file->stringify,
            ">$icc_profile",
        );
        system($cmd, @options);
        # INFO($stdout);
        # INFO("Error: $stderr") if $stderr;
    }
    my $tiff_out_path     = path($tiff_dst, $tiff_basename);
    my $data = $gcp_file->slurp;
    
    my @lines  = split "\n", $data;
    my @header = split ',', shift @lines;
    
    LOGCROAK('Unexpected header') unless @header == @header_expected;
    for (my $i = 0; $i <= $#header; $i++) {
        LOGCROAK('Unexpected header') unless $header[$i] eq $header_expected[$i];
    } 
    
    my (%row, @coords);
    foreach my $line ( @lines ) {
        next if $line =~ /^\s*$/;
        @row{@header} = map { s/^\s+|\s+$//gr }  split ',', $line;
        push @coords, { %row };
    }
    
    my $cmd =  'gdal_translate';
    
    my @options = (
        -of   => 'GTiff',
        -a_srs => $srs, 
    ); 
    
    foreach my $coord (@coords) {
        next unless $coord->{enable} == 1;
        push @options, '-gcp';
        push @options, 
            sprintf("%.6g",   $coord->{pixelX}),
            sprintf("%.6g", - $coord->{pixelY}),
            sprintf("%.6g",   $coord->{mapX}),
            sprintf("%.6g",   $coord->{mapY}),
        ;
    }
    INFO(join ' ', $cmd, @options);
    
    my ($stdout, $stderr, $exit) = tee {
        system($cmd, @options, $tiff_file, $tiff_out_path);
    };
    INFO($stdout);
    INFO("Error: $stderr") if $stderr;
    my $tiff_out = Remedi::Imagefile->new(
        file => $tiff_out_path,
    );
    if ($icc_profile) { 
       INFO('ICC profile: ', $tiff_out->icc_profile || 'no icc profile');
       unless ($tiff_out->icc_profile) {
           my $cmd = 'exiftool';
           my @options = (
               "-icc_profile=$icc_profile",
               $tiff_out_path,
           );
           my ($stdout, $stderr, $exit) = tee {
               system($cmd, @options);
           };
           INFO($stdout);
           INFO("Error: $stderr") if $stderr;
       }
    }
}

