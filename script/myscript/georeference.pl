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
use UBR::Geo::GCP;

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
    my $gcp = UBR::Geo::GCP->new( file => $gcp_file );
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
        -a_srs => $srs, 
    ); 
    
    foreach my $coord (@coords) {
        push @options, '-gcp';
        push @options, 
            sprintf("%.6g",   $coord->{GCPPixel}),
            sprintf("%.6g", - $coord->{GCPLine}),
            sprintf("%.6g",   $coord->{GCPX}),
            sprintf("%.6g",   $coord->{GCPY}),
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

