use utf8;
package UBR::Geo::GCP;

# ABSTRACT: Role for Groundcontrol points (GCP)

use Moose::Role;
    requires qw(_build_gcps srid);
    
use MooseX::AttributeShortcuts;
use Geo::GDAL;
use UBR::Geo::Types qw(
    ArrayRef  GeoGDALGCP GeoGDALGeoTransform HashRef Num Str
);
use Data::Dumper;
use Modern::Perl;
use List::Util qw(first min max);


has 'gcps' => (
    is => 'lazy',
    isa => ArrayRef[GeoGDALGCP],	
);

has 'gcps_as_href' => (
    is => 'lazy',
    isa => ArrayRef[HashRef[Str]],
);


has 'gcps_convex_hull' => (
    is => 'lazy',
    isa => ArrayRef[GeoGDALGCP],
);


has 'segment_length' => (
    is => 'lazy',
    isa => Num,
);

has 'srid' => (
    is => 'ro', 
    required => 1,
    isa => Str,
);    

sub _build_gcps_as_href {
    my $self = shift;

    my @coords = map { {
        pixel => $_->{GCPPixel},
        line  => $_->{GCPLine},
        x     => $_->{GCPX},
        y     => $_->{GCPY},
        z     => $_->{GCPZ},
        id    => $_->{Id}, 
        info  => $_->{Info},
    } } @{$self->gcps};

    return \@coords;
}

sub _build_gcps_convex_hull {
    my $self = shift;

    # points must be sorted (anti-)clockwise to get a simple geometry
    # we build a convex hull around
    # this guarantees a correct order of points 

    my @coords = @{$self->gcps_as_href}; 

    # get pixel coordinates
    my @points = map { [$_->{pixel}, $_->{line}] }  @coords;

    # build a multipoint geometry
    my $multipoint = Geo::OGR::Geometry->create('MultiPoint');
    $multipoint->Points([@points]);

    # .. with a hull
    my $convex_hull = $multipoint->ConvexHull();

    # get the points back
    my @points_sorted = @{$convex_hull->Points->[0]};
     
    # walk through sorted points, search for matching original
    # put a sort label on it
    for (my $i = 0; $i < $#points_sorted; $i++) {   # last = first point
        my @point = @{ $points_sorted[$i] };

        my $coord = first { 
                $_->{pixel} == $point[0] 
                    && 
                $_->{line} == $point[1] 
            } @coords; 
        
        die "Ordering points failed!" unless $coord;
        $coord->{sort} = $i;
    }

    #say Dumper(\@coords);

    my @gcps = map {
        Geo::GDAL::GCP->new( 
            @{$_}{ qw(x y z pixel line id info) } 
        );
    }  sort { $a->{sort} <=> $b->{sort} } @coords;
    return \@gcps;    
}

sub _build_segment_length {
    my $self = shift;

    # maximal segment length should be around 1 cm for images with 400 dpi.
    my @gcps  = @{$self->gcps};
    my @gcpX  = map { $_->{GCPX}     } @gcps;
    my $maxX  = max @gcpX;
    my $minX  = min @gcpX;
    my @gcpPx = map { $_->{GCPPixel} } @gcps;
    my $maxPx = max @gcpPx;
    my $minPx = min @gcpPx;

    # 400 dpi, 2.54 cm / inch 
    my $seg = ($maxX - $minX) / ($maxPx - $minPx) * 400 / 2.54; 
    return $seg;
}

1;

