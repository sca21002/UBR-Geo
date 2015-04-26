#!/usr/bin/env perl
use utf8;
use Carp;
use Config::ZOMG;
use Data::Dumper;
use FindBin qw($Bin);
use Path::Tiny;
use lib path($Bin)->parent(2)->child('lib')->stringify;
use English qw( -no_match_vars );   # Avoids regex performance penalty
use UBR::Geo::OGR::DataSource::Pg;
use Modern::Perl;
use Getopt::Long;
use Pod::Usage;
use Log::Log4perl qw(:easy);
use Getopt::Long;

my $logfile = path($Bin)->parent(2)->child(
    'change_negative_sign_boundary_px.log'
);

### initialise log file
Log::Log4perl->easy_init(
    { level   => $DEBUG,
      file    => ">" . $logfile,
    },
    { level   => $TRACE,
      file    => 'STDOUT',
    },
);

### get options

my ($opt_help, $opt_man);

GetOptions (
    'help!'        => \$opt_help,
    'man!'         => \$opt_man,
) or pod2usage( "Try '$PROGRAM_NAME --help' for more information." );

pod2usage( -verbose => 1 ) if $opt_help;
pod2usage( -verbose => 2 ) if $opt_man;


my $pg_datasource = UBR::Geo::OGR::DataSource::Pg->new();
my $pg_lyr_boundary_px = $pg_datasource->get_layer('boundaries(boundary_px)');

$pg_lyr_boundary_px->SetAttributeFilter("boundary_px IS NOT NULL"); 
while (my $boundary_px = $pg_lyr_boundary_px->GetNextFeature()) {
    my $geom = $boundary_px->Geometry;
    unless ($geom) {
        LOGCORAK("Got no geometry");
    }
    my $fid = $boundary_px->GetFID();
    LOGCORAK("No fid found") unless $fid;
    INFO("FID: '$fid'");
    my $geom_type = $geom->GeometryType();
    LOGCROAK("Wrong geometry type '$geom_type'; 'MultiPolygon' expected")
        unless $geom_type eq 'MultiPolygon';

    my $multipolygon_dst = Geo::OGR::Geometry->create('MultiPolygon');    
    my $multipolygon_src = $geom->Points();  # a multipolygon is a list of polygons
    my $dirty;

    foreach my $polygon_src (@$multipolygon_src) {
        my $polygon_dst = Geo::OGR::Geometry->create('Polygon');

        foreach my $ring_src (@$polygon_src) { # a polygon is a list of rings
            my $ring_dst = Geo::OGR::Geometry->create('LinearRing');
            foreach my $point_src (@$ring_src) {
                my($x, $y) = @$point_src;
                if ($y < 0 ) {
                     $y = -$y;
                     $dirty = 1;
                }
                $x = sprintf("%.0f", $x);
                $y = sprintf("%.0f", $y);
                INFO("x: '$x', y: '$y'");
                $ring_dst->AddPoint($x, $y);
            }
            $polygon_dst->AddGeometry($ring_dst);
        }
        $multipolygon_dst->AddGeometry($polygon_dst);
    }    
    INFO("No negative pixel_y found") unless $dirty;
    $boundary_px->Geometry($multipolygon_dst);
    $pg_lyr_boundary_px->SetFeature($boundary_px);
    INFO("Boundary_px updated");
}


=encoding utf-8

=head1 NAME
 
change_negative_sign_boundary_px.pl - Change sign of pixel_y of boundary_px   

=head1 SYNOPSIS

change_negative_sign_boundary_px.pl [options]  

 Options:
   --help         display this help and exit
   --man          display extensive help


 Examples:
   cange_negative_sign_boundary_px.pl --order_id ubr15411 --tiff_dir ubr15411/mst/tif   
   change_negative_sign_boundary_px.pl --help
   change_negative_sign_boundary_px.pl --man 
   

=head1 DESCRIPTION

Change sign of pixel_y of boundary_px

Y coordinates of boundaries in pixel coordinates have negiative values 
introduced by a bug in the loading script. 
This script fixes this erroneous values.

=head1 AUTHOR

Albert Schröder <albert.schroeder@ur.de>

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
