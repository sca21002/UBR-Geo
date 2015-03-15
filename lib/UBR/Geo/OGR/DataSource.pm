use utf8;
package UBR::Geo::OGR::DataSource;

# ABSTRACT: OGR datasource

use Geo::OGR;
use Moose;
use MooseX::AttributeShortcuts;
use UBR::Geo::OGR::Layer;
use UBR::Geo::Types qw(Bool GeoOGRDataSource GeoOGRDriver Str);

has 'connectstr' => ( is => 'ro', isa => Str);

has 'drivername' => ( is => 'ro', isa => Str );

has 'update' => ( is => 'ro', isa => Bool );

has 'driver' => ( 
    is => 'lazy', 
    isa => GeoOGRDriver,
);

has 'datasource' => (
    is => 'lazy',
    isa => GeoOGRDataSource,
    handles => [qw(GetLayerByName Layers)],
);

sub _build_datasource {
    my $self = shift;

    return $self->driver->Open($self->connectstr, $self->update);
}

sub _build_driver {
    my $self = shift;

    my $driver = Geo::OGR::GetDriverByName($self->drivername)
        or confess "Driver '" . $self->drivername ."' not available";
    return $driver;
}

sub get_layer {
    my ($self, $layername) = @_;

    confess("No layername given") unless $layername;
    return UBR::Geo::OGR::Layer->new( $self->GetLayerByName($layername) );	
}

__PACKAGE__->meta->make_immutable();

1;
