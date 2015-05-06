use utf8;
package UBR::Geo::Geotransform;

# ABSTRACT: Role for Geotransformation

use Moose::Role;
    
use MooseX::AttributeShortcuts;
use Geo::GDAL;
use UBR::Geo::Types qw(
    GeoGDALGeoTransform HashRef Num Str
);
use Data::Dumper;
use Modern::Perl;

has 'upperleft_x' => ( 
    is => 'rw', 
    isa => Num,
);    

has 'scale_x' => (
    is => 'rw', 
    isa => Num,
);

has 'skew_y' => ( 
    is => 'rw', 
    isa => Num,
);

has 'upperleft_y' => ( 
    is => 'rw', 
    isa => Num,
);

has 'skew_x' => ( 
    is => 'rw', 
    isa => Num,
);

has 'scale_y' => ( 
    is => 'rw', 
    isa => Num,
);

has 'srid' => (
    is => 'rw', 
    isa => Str,
);   

has 'as_href' => (
    is => 'lazy',
    isa => HashRef[Str],
);

has 'GDALgeotransform' => (
    is => 'lazy',
    isa => GeoGDALGeoTransform,
);

sub _build_GDALgeotransform {
    my $self = shift;

    my @params =  qw(upperleft_x scale_x skew_y upperleft_y skew_x scale_y); 
    my @GDALgeotransform = map { $self->$_ } @params;
    return \@GDALgeotransform;
}

sub _build_as_href {
    my $self = shift;

    my @columns = qw(
        upperleft_x scale_x skew_y upperleft_y skew_x scale_y srid
    );
    my %href = map { $_ => $self->$_ } @columns;
    return \%href;
}

#sub new_from_gcps {
#    my ($class, $gcp) = @_;
#     
#    my @params =  qw(upperleft_x scale_x skew_y upperleft_y skew_x scale_y); 
#    my @GDALgeotransform = Geo::GDAL::GCPsToGeoTransform($gcp->gcps);
#    my %geotransform;
#    @geotransform{@params} = @GDALgeotransform;
#    $geotransform{srid} = $gcp->srid;
#    #say Dumper(%geotransform);
#    my $self = $class->new({%geotransform});
#    return $self;    
#}


sub transform_pixel {
    my ($self, $pixelX, $pixelY, $srid ) = @_;

    #warn "TEST:", $pixelX, $pixelY, $srid;

    return unless defined($pixelX) && defined($pixelY) && $srid;

    my ($x, $y) 
        = Geo::GDAL::ApplyGeoTransform($self->GDALgeotransform, $pixelX, $pixelY);

    ($x, $y) = coordinate_transformation($x, $y, $self->srid, $srid);

    return ($x, $y);
}

sub transform_invers {
    my ($self, $x, $y, $srid) = @_;

    return unless defined($x) && defined($y) && $srid;

    ($x, $y) = coordinate_transformation($x, $y, $srid, $self->srid);

    
    my $inv = Geo::GDAL::InvGeoTransform($self->GDALgeotransform);

    my ($pixel_x, $pixel_y) 
        = Geo::GDAL::ApplyGeoTransform($inv, $x, $y); 

    return ($pixel_x, $pixel_y);
}    

sub coordinate_transformation{
    my($x_src, $y_src, $srid_src, $srid_dst) = @_;

    return $x_src, $y_src if $srid_src eq $srid_dst;
    my $srs_src = Geo::OSR::SpatialReference->create(EPSG => $srid_src);
    my $srs_dst = Geo::OSR::SpatialReference->create(EPSG => $srid_dst);
    my $coordinate_transformation 
        = Geo::OSR::CoordinateTransformation->new($srs_src, $srs_dst);
    my ($x_dst, $y_dst) 
        = $coordinate_transformation->TransformPoint($x_src, $y_src);        
    return $x_dst, $y_dst;
}

=encoding utf8

=head1 AUTHOR

GIS user,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1; # Magic true value required at end of module
 
__END__
