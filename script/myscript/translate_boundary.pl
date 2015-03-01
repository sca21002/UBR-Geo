#!/usr/bin/env perl
use utf8;
use Carp;
use Config::ZOMG;
use Data::Dumper;
use FindBin qw($Bin);
use Path::Tiny;
use lib path($Bin)->parent(3)->child(qw(Remedi lib))->stringify;
use Remedi::Imagefile;
use Geo::OGR;
use Geo::GDAL;
use Modern::Perl;


my $shp_drivername = 'ESRI Shapefile';
my $shp_driver = Geo::OGR::GetDriverByName($shp_drivername)
	or confess "Driver '" . $shp_drivername ."' not available";

my $shp_filename = '/home/gis/UBR-Geo/data/boundary.shp';
my $shp_datasource = $shp_driver->Open($shp_filename);

my $shp_lyr_boundary = $shp_datasource->GetLayerByName('boundary');

my $config_dir = path($Bin)->parent(2);
my $config_hash = Config::ZOMG->open(
    name => 'ubr_geo',
    path => $config_dir,
) or confess "No config file found in $config_dir";

my $connect_info = $config_hash->{"Model::UBR::GeoDB"}{"connect_info"};

my ($dbname) = $connect_info->{dsn} =~ /dbi:Pg:dbname=(.*)$/;
my $user = $connect_info->{user};
my $password = $connect_info->{password} || '';
my $connectstr =  "Pg:dbname='$dbname' user='$user' password='$password'";
my $update = 1;


my $pg_drivername = 'PostgreSQL';
my $pg_driver = Geo::OGR::GetDriverByName($pg_drivername)
	or confess "Driver '" . $pg_drivername ."' not available";
my $pg_datasource = $pg_driver->Open($connectstr, $update);
my $pg_lyr_boundary   =  $pg_datasource->GetLayerByName('maps(boundary_wld)');

my $pg_lyr_boundary_px   =  $pg_datasource->GetLayerByName('maps(boundary_px)');


while (my $boundary = $shp_lyr_boundary->GetNextFeature()) {
    my $fid = $boundary->GetFID();
    my $basename = $boundary->{filename};
    
    $pg_lyr_boundary->SetAttributeFilter("filename = '$basename'");
    my $maybe_boundary = $pg_lyr_boundary->GetNextFeature();
    my $boundary_exists;
    if ($maybe_boundary) {
        my $fid = $maybe_boundary->GetFID();
        say "Boundary $basename with fid $fid found in database. Skipping ...";
        $boundary_exists = 1;
    }
    next if $boundary_exists;

    my ($order_id) = $basename =~ /^(ubr\d{5})_\d{1,5}$/;
    say "Working on: $fid: $basename";
    my $file = path('/media/sca21002/rzblx9/scanflow/final/', $order_id, '/mst/tif/', $basename .'.tif');
    my $tiff = Remedi::Imagefile->new(
        file => $file,	
        regex_filestem_prefix => qr/^ubr\d{5}/,
        regex_filestem_var => qr/_\d{1,5}/,
        size_class_border => 100,
    );
    my $dataset = Geo::GDAL::Open( $tiff->stringify, 'ReadOnly' );
    my $transformer = Geo::GDAL::Transformer->new( $dataset, undef, [ 'METHOD=GCP_POLYNOMIAL' ] );	

    my $geom = $boundary->Geometry;
    if ($geom) {
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
                # say "Point: $x_src, $y_src";
                my ($success, $x_dst, $y_dst, $z_dst) = $transformer->TransformPoint( 0, $x_src, $y_src );
                # say "x: $x_dst y: $y_dst";
                $ring_dst->AddPoint($x_dst,$y_dst);
            }
            $polygon_dst->AddGeometry($ring_dst);
        }
        $multipolygon_dst->AddGeometry($polygon_dst);
        my $pg_boundary = Geo::OGR::Feature->create($pg_lyr_boundary->Schema);
        $pg_boundary->SetField(filename => $basename);    
        $pg_boundary->SetField(resolution => $tiff->resolution);    
        $pg_boundary->Geometry($multipolygon_dst);
        my $resolution = $tiff->resolution;
        say "resolution: $resolution";
        my $area_map = $geom_simple->Area / ( $resolution / 2.54 * 100) ** 2;
        say "Area px: " . $geom_simple->Area;
        say "Area wld: " . $polygon_dst->Area;
        say "Area map: $area_map";
        my $area_wld = $polygon_dst->Area;
        my $scale =  sqrt ( $area_wld / $area_map );
        $scale = sprintf("%.3g",$scale);         
        say "Scale: $scale";
        $scale = sprintf("%d", $scale);
        say "Masstab: 1 : $scale"; 
        $pg_boundary->SetField(resolution => $resolution);
        $pg_boundary->SetField(scale => $scale);
 
        $pg_lyr_boundary->InsertFeature($pg_boundary);
        $pg_lyr_boundary_px->SetAttributeFilter("filename = '$basename'");
        my $pg_boundary_px = $pg_lyr_boundary_px->GetNextFeature();
        if ($pg_boundary_px) {
	    $pg_boundary_px->Geometry($geom_simple);
            $pg_lyr_boundary_px->SetFeature($pg_boundary_px);
        }
    }
    # last if $basename eq 'ubr16043_0263';
}

