#!/usr/bin/env perl
use utf8;
use Carp;
use Config::ZOMG;
use Data::Dumper;
use FindBin qw($Bin);
use Path::Tiny;
use lib path($Bin)->parent(2)->child('lib')->stringify,
        path($Bin)->parent(3)->child(qw(Remedi lib))->stringify;
use Remedi::Imagefile;
use Geo::OGR;
use English qw( -no_match_vars );   # Avoids regex performance penalty
use UBR::Geo::OGR::DataSource::Pg;
use Geo::GDAL;
use Modern::Perl;
use Getopt::Long;
use Pod::Usage;
use Log::Log4perl qw(:easy);
use Getopt::Long;

my $logfile = path($Bin)->parent(2)->child('translate_boundary.log');

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

my ($order_id, $shp_file, $tiff_dir, $opt_help, $opt_man);

GetOptions (
    "order_id=s"   => \$order_id,
    "shp=s"        => \$shp_file,
    "tiff_dir=s"   => \$tiff_dir,
    'help!'        => \$opt_help,
    'man!'         => \$opt_man,
) or pod2usage( "Try '$PROGRAM_NAME --help' for more information." );

pod2usage( -verbose => 1 ) if $opt_help;
pod2usage( -verbose => 2 ) if $opt_man;

pod2usage( -verbose => 1 ) unless $order_id && $tiff_dir;

if ($shp_file) {
    $shp_file = path($shp_file);
} else {    
    $shp_file = path($Bin)->parent(2)->child('data', 'boundary.shp');
}    
$tiff_dir = path($tiff_dir);

INFO("Order: '$order_id'");
INFO("Directory of archive TIFFs: '$tiff_dir'");
INFO("Shapefile: '$shp_file'");

LOGCROAK("Shapefile doesn't exist")
    unless $shp_file->is_file;
LOGCROAK("TIFF dir doesn't exist")
    unless $tiff_dir->is_dir;


my $shp_drivername = 'ESRI Shapefile';
my $shp_driver = Geo::OGR::GetDriverByName($shp_drivername)
	or confess "Driver '" . $shp_drivername ."' not available";

my $shp_datasource = $shp_driver->Open($shp_file->stringify);

my $shp_lyr_boundary = $shp_datasource->GetLayerByName('boundary');

my $pg_datasource = UBR::Geo::OGR::DataSource::Pg->new();
my $pg_lyr_boundary = $pg_datasource->get_layer('boundaries(boundary_wld)');
my $pg_lyr_map      = $pg_datasource->get_layer('maps');
my $pg_lyr_boundary_px = $pg_datasource->get_layer('boundaries(boundary_px)');

$shp_lyr_boundary->SetAttributeFilter("filename LIKE '${order_id}_%'"); 
# $shp_lyr_boundary->SetAttributeFilter("filename = 'ubr15411_0134'");;
while (my $boundary = $shp_lyr_boundary->GetNextFeature()) {
    #my $fid = $boundary->GetFID();
    my $basename = $boundary->{filename};
    
    INFO("Boundary for '$basename' found."); 
    my $map_id;    
    if ($map_id = $pg_lyr_map->get_feature( {filename => $basename} ) ) {
        INFO(
            "Map $basename with map_id $map_id found in database. Skipping ..."
        ); 
        next;
    } 

    INFO("Working on: $map_id: $basename");

    my $tiff_file = $tiff_dir->child($basename .'.tif');
    my $tiff = Remedi::Imagefile->new(
        file => $tiff_file,	
        regex_filestem_prefix => qr/^ubr\d{5}/,
        regex_filestem_var => qr/_\d{1,5}/,
        size_class_border => 100,
    );
    my $dataset = Geo::GDAL::Open( $tiff->stringify, 'ReadOnly' );
    my $transformer = Geo::GDAL::Transformer->new( $dataset, undef, [ 'METHOD=GCP_POLYNOMIAL' ] );	

    my $geom = $boundary->Geometry;
    unless ($geom) {
        LOGCORAK("Got no geometry for $basename from shapefile $shp_file");
    }
    say "Type: ", $geom->GeometryType();
    #say "Points:", Dumper($geom->Points());
    my $geom_simple = $geom->Simplify(12);
    my $geom_segmented   = $geom_simple->Clone();
    #say "Points:", Dumper($geom_new->Points());
    $geom_segmented->Segmentize(118);
    #say "Points:", Dumper($geom_new->Points());

    my $multipolygon_dst = Geo::OGR::Geometry->create('MultiPolygon');    
    my $polygon_dst = Geo::OGR::Geometry->create('Polygon');
    my $rings_src = $geom_segmented->Points();     # a polygon is a list of rings 
    foreach my $ring_src (@$rings_src) {
        my $ring_dst = Geo::OGR::Geometry->create('LinearRing');
        foreach my $point_src (@$ring_src) {
            my($x_src, $y_src) = @$point_src;
            $y_src = -$y_src;
            say sprintf("x: %.0f, y: %.0f", $x_src, $y_src);
            my ($success, $x_dst, $y_dst, $z_dst) = $transformer->TransformPoint( 0, $x_src, $y_src );
            say sprintf("x: %.6g, y: %.6g", $x_dst, $y_dst);
            $ring_dst->AddPoint($x_dst,$y_dst);
        }
        $polygon_dst->AddGeometry($ring_dst);
    }
    $multipolygon_dst->AddGeometry($polygon_dst);

    my $pg_boundary = Geo::OGR::Feature->create($pg_lyr_boundary->Schema);
    $pg_boundary->Geometry($multipolygon_dst);
    # with InsertFeature no FID can be got  
    # $pg_lyr_boundary->InsertFeature($pg_boundary);
    # so CreateFeature is used instead
    $pg_lyr_boundary->CreateFeature($pg_boundary);
    my $fid = $pg_boundary->GetFID();
    say "Newly inserted geom with FID: ", $fid;
    my $pg_map = Geo::OGR::Feature->create($pg_lyr_map->Schema);
    $pg_map->SetField(boundary_id => $fid );    
    $pg_map->SetField(filename => $basename);    
    $pg_map->SetField(resolution => $tiff->resolution);    
    my $resolution = $tiff->resolution;
    say "resolution: $resolution";
#    my $area_map = $geom_simple->Area / ( $resolution / 2.54 * 100) ** 2;
#    say "Area px: " . $geom_simple->Area;
#    say "Area wld: " . $multipolygon_dst->Area;
#    say "Area map: $area_map";
#    my $area_wld = $multipolygon_dst->Area;
#    my $scale =  sqrt ( $area_wld / $area_map );
#    $scale = sprintf("%.3g",$scale);         
#    say "Scale: $scale";
#    $scale = sprintf("%d", $scale);
#    say "Masstab: 1 : $scale"; 
#    $pg_map->SetField(scale => $scale);
    $pg_lyr_map->InsertFeature($pg_map);
 
 
    my $multipolygon_px = Geo::OGR::Geometry->create('MultiPolygon');      
    $multipolygon_px->AddGeometry($geom_simple); 
    $pg_lyr_boundary_px->SetAttributeFilter("fid = $fid");
    my $pg_boundary_px = $pg_lyr_boundary_px->GetNextFeature();
    if ($pg_boundary_px) {
    $pg_boundary_px->Geometry($multipolygon_px);
        $pg_lyr_boundary_px->SetFeature($pg_boundary_px);
    }
    # last if $basename eq 'ubr16043_0263';
}

=encoding utf-8

=head1 NAME
 
translate_boundary.pl - Get boundaries from shapefile   

=head1 SYNOPSIS

translate_boundary.pl [options]  

 Options:
   --help         display this help and exit
   --man          display extensive help

   --order_id     Order id of Atacama database      
   --tiff_dir     Directory of Tiff Archive files
   --shp          Shapefile with boundaries
                  (default: data/boundary.shp)

 Examples:
   translate_boundary.pl --order_id ubr15411 --tiff_dir ubr15411/mst/tif   
   translate_boundary.pl --help
   translate_boundary.pl --man 
   

=head1 DESCRIPTION

Get boundaries from shapefile

Boundaries n pixel coordinates of the maps are read from a ESRI shapefile.
Transformation from pixel coordinates to geographical coordinates is got 
from TIFF archive files in GeoTIFF format. Boundaries are translated into
coordinates of the destination spatial reference system (SRS). Boundaries
in both coordination systems (pixel and srs) are saved in the PostGIS 
database.

=head1 AUTHOR

Albert Schröder <albert.schroeder@ur.de>

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
