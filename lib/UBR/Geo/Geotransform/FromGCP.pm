use utf8;
package UBR::Geo::Geotransform::FromGCP;

# ABSTRACT: Class for Geotransformation with GCPs from DB

use Moose;
    with 'UBR::Geo::Geotransform';   

use MooseX::AttributeShortcuts;
use Geo::GDAL;
use UBR::Geo::Types qw(UBRGeoGCP);
use Modern::Perl;

has 'gcp' => (
    is => 'ro',
    required => 1,
    isa => UBRGeoGCP,
);


sub BUILD {
    my $self = shift;

    my @params =  qw(upperleft_x scale_x skew_x upperleft_y skew_y scale_y); 
    my @GDALgeotransform = Geo::GDAL::GCPsToGeoTransform($self->gcp->gcps);
    my %geotransform;
    @geotransform{@params} = @GDALgeotransform;
    $geotransform{srid} = $self->gcp->srid;
    foreach my $key (keys %geotransform) {
        $self->$key( $geotransform{$key} );
    };
}

__PACKAGE__->meta->make_immutable;

=encoding utf8

=head1 AUTHOR

GIS user,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1; # Magic true value required at end of module
 
__END__
