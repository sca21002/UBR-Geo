#!/usr/bin/env perl
use utf8;
use Path::Tiny;
use FindBin qw($Bin);
use lib path($Bin)->parent(2)->child(lib)->stringify;
use Data::Dumper;
use English qw( -no_match_vars );   # Avoids regex performance penalty
use Modern::Perl;
use Getopt::Long;
use Log::Log4perl qw(:easy);
use Pod::Usage;
use UBR::Geo::OGR::DataSource::Pg;
use UBR::Geo::GCP::FromFile;
use Geo::OSR;

my $logfile = path($Bin)->parent(1)->child('boundary_from_gcp.log');

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

my ($gcp_dir, $srs, $resolution, $opt_help, $opt_man);

GetOptions (
    "gcp_dir=s"    => \$gcp_dir,
    "srs=s"        => \$srs,
    "resolution=s" => \$resolution,
    'help!'        => \$opt_help,
    'man!'         => \$opt_man,
) or pod2usage( "Try '$PROGRAM_NAME --help' for more information." );

pod2usage( -verbose => 1 ) if $opt_help;
pod2usage( -verbose => 2 ) if $opt_man;

pod2usage( -verbose => 1 ) unless $gcp_dir && $srs && $resolution;


$gcp_dir  = path($gcp_dir);

INFO('Groundcontrolpoint dir: ' . $gcp_dir);
INFO('Projection:             ' . $srs);
INFO('Resolution:             ' . $resolution); 

LOGCROAK("Directory of groundcontrolpoints doesn't exist")
    unless $gcp_dir->is_dir;

my $pg_datasource = UBR::Geo::OGR::DataSource::Pg->new();

my @gcp_files = path($gcp_dir)->children( qr/\.tif\.points$/ );

INFO(scalar @gcp_files, " groundcontrolpoint files found");

foreach my $gcp_file (sort @gcp_files) {
    INFO("Working  $gcp_file");
    my $gcp = UBR::Geo::GCP::FromFile->new( file => $gcp_file );
    write_gcps($pg_datasource, $gcp, $srs, $resolution); 
}


sub write_gcps {
    my ($pg_datasource, $gcp, $srs, $resolution) = @_; 

    my $pg_lyr_boundary = $pg_datasource->get_layer('boundaries(boundary_wld)');
    my $pg_lyr_map = $pg_datasource->get_layer('maps');
    my $pg_lyr_boundary_px 
        = $pg_datasource->get_layer('boundaries(boundary_px)');
    
    INFO('Image filename: ', $gcp->filestem);
    
    if (my $fid = $pg_lyr_map->get_feature( {filename => $gcp->filestem} ) ) {
        INFO("Map ", 
             $gcp->filestem, 
             " with map_id $fid found in database. Skipping ...");
        return;
    } 
    
    my @points_px = map { [ $_->{GCPPixel}, $_->{GCPLine} ] } 
        @{$gcp->gcps_convex_hull};
    
    my $multipolygon_px = Geo::OGR::Geometry->create('MultiPolygon');
    $multipolygon_px->Points( [[[ @points_px ]]] );

    my @points_wld = map { [ $_->{GCPX}, $_->{GCPY} ] }  
        @{$gcp->gcps_convex_hull};
    
    my $multipolygon_wld = Geo::OGR::Geometry->create('MultiPolygon');
    $multipolygon_wld->Points( [[[ @points_wld ]]] );

    $multipolygon_wld->Segmentize($gcp->segment_length);

    my $src = Geo::OSR::SpatialReference->create(EPSG => $srs); 
    my $dst = Geo::OSR::SpatialReference->create(EPSG => 3857);
    my $transform = Geo::OSR::CoordinateTransformation->new($src, $dst);
    
    my $mp = $multipolygon_wld->Points();
    $transform->TransformPoints($mp);
    $multipolygon_wld->Points($mp);
    
    INFO('Geometry created: ', $multipolygon_wld->GetGeometryName());
    INFO(' with ', scalar @{$multipolygon_wld->Points()->[0][0]}, ' Points');

    my $pg_boundary = Geo::OGR::Feature->create($pg_lyr_boundary->Schema);
    $pg_boundary->Geometry($multipolygon_wld);
    # with InsertFeature no FID can be got  
    # $pg_lyr_boundary->InsertFeature($pg_boundary);
    # so CreateFeature is used instead
    $pg_lyr_boundary->CreateFeature($pg_boundary);
    my $fid = $pg_boundary->GetFID();
    say "Newly inserted geom with FID: ", $fid;
    my $pg_map = Geo::OGR::Feature->create($pg_lyr_map->Schema);
    $pg_map->SetField(boundary_id => $fid );    
    $pg_map->SetField(filename => $gcp->filestem);    
    $pg_map->SetField(resolution => $resolution);    
    INFO("Resolution: $resolution");

    my $area_map = $multipolygon_px->Area / ( $resolution / 2.54 * 100) ** 2;
    my $area_wld = $multipolygon_wld->Area;
    my $scale    = sqrt ( $area_wld / $area_map );
    $scale = sprintf("%.3g",$scale);
    $scale = sprintf("%d", $scale);
    INFO("Masstab: 1 : $scale"); 

    $pg_map->SetField(scale => $scale);
    $pg_lyr_map->InsertFeature($pg_map);

    $pg_lyr_boundary_px->SetAttributeFilter("fid = $fid");
    my $pg_boundary_px = $pg_lyr_boundary_px->GetNextFeature();
    if ($pg_boundary_px) {
        $pg_boundary_px->Geometry($multipolygon_px);
        $pg_lyr_boundary_px->SetFeature($pg_boundary_px);
    }
}

=encoding utf-8

=head1 NAME
 
boundary_from_gcp.pl - build a boundary around map content  

=head1 SYNOPSIS

boundary_from_gcp.pl [options]  

 Options:
   --help         display this help and exit
   --man          display extensive help

   --gcp_dir      directory of files with ground control points (GCPs)
   --srs          spatial reference system (SRS)
   --resolution   resolution of scanned images

 Examples:
   boundary_from_gcp.pl --gcp_dir t/input_files --srs 3857 --resolution 400  
   boundary_from_gcp.pl --help
   boundary_from_gcp.pl --man 
   

=head1 DESCRIPTION

Build a boundary around map content based on ground control points  

If a map has a graticule with intersections on the 4 corners of
the map, the ground control points (GCP) can be set on the corners and 
the GCPs build a rectangular describing the map content. 

=head1 AUTHOR

Albert Schröder <albert.schroeder@ur.de>

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
