use utf8;
package UBR::Geo::GCP;

# ABSTRACT: Groundcontrol points file

use Moose;
use MooseX::AttributeShortcuts;
use Geo::GDAL;
use UBR::Geo::Types qw(ArrayRef File GeoGDALGCP HashRef Num Str);
use Data::Dumper;
use Modern::Perl;
use List::Util qw(first min max);
use Carp;

has 'file' => (
    is => 'ro',
    isa => File,
    handles => [qw(basename)],
    coerce => 1,
    required => 1,
);

has 'filestem' => (
    is => 'lazy',
    isa => Str,
);

has 'header' => (
    is => 'lazy',
    isa => ArrayRef[Str], 
);


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

has 'geotransform' => (
    is => 'lazy',
    isa => ArrayRef[Num],
);

has 'segment_length' => (
    is => 'lazy',
    isa => Num,
);


sub _build_gcps {
    my $self = shift;

    my $data = $self->file->slurp;
   
    my @lines  = split "\n", $data;
    my @header = split ',', shift @lines;
    
    die('Unexpected header ' . join('|', @header . " <> " . join('|', @{$self->header})) ) 
	unless join('|', @header) eq join('|', @{$self->header});
    
    my (%row, @coords);
    foreach my $line ( @lines ) {
        next if $line =~ /^\s*$/;
        if ( exists $row{enable} && $row{enable} eq 0 ) {
            carp "line '$line' left out as GCP";
        }
        @row{@header} = map { s/^\s+|\s+$//gr }  split ',', $line;
        $row{pixelX} = sprintf "%.0f", $row{pixelX};
        $row{pixelY} = sprintf "%.0f", $row{pixelY};
        push @coords, { %row };
    }
   
    my @gcps = map {
        Geo::GDAL::GCP->new( @{$_}{ qw(mapX mapY mapZ pixelX pixelY) } )
    }  @coords;
    return \@gcps;    
}

sub _build_gcps_as_href {
    my $self = shift;

    my @coords = map { {
        GCPPixel => $_->{GCPPixel},
        GCPLine  => $_->{GCPLine},
        GCPX     => $_->{GCPX},
        GCPY     => $_->{GCPY},
        GCPZ     => $_->{GCPZ},
        Id       => $_->{Id}, 
        GCP      => $_->{Info},
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
    my @points = map { [$_->{GCPPixel}, $_->{GCPLine}] }  @coords;

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
                $_->{GCPPixel} == $point[0] 
                    && 
                $_->{GCPLine} == $point[1] 
            } @coords; 
        
        die "Ordering points failed!" unless $coord;
        $coord->{sort} = $i;
    }

    #say Dumper(\@coords);

    my @gcps = map {
        Geo::GDAL::GCP->new( 
            @{$_}{ qw(GCPX GCPY GCPZ GCPPixel GCPLine Id Info) } 
        );
    }  sort { $a->{sort} <=> $b->{sort} } @coords;
    return \@gcps;    
}


sub _build_geotransform { Geo::GDAL::GCPsToGeoTransform((shift)->gcps) }


sub _build_filestem {
    my $self = shift;
    
    my ($filestem) = $self->basename =~ qr/^([^.]*)\./;
    return $filestem;
}


sub _build_header { [ qw(mapX mapY pixelX pixelY enable) ] }


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


sub transform_pixel {
    my ($self, $pixelX, $pixelY ) = @_;

    # warn "TEST:", $pixelX, $pixelY;

    return unless defined($pixelX) && defined($pixelY);

    my @tr = @{$self->geotransform};

    my $x = $tr[0] + $pixelX * $tr[1] + $pixelY * $tr[2];
    my $y = $tr[3] + $pixelX * $tr[4] + $pixelY * $tr[5];

    return ($x, $y);
}


__PACKAGE__->meta->make_immutable();

1;

