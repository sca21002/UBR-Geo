use utf8;
package UBR::Geo::Geotransform::FromDB;

# ABSTRACT: Class for Geotransformation with data from DB

use Moose;
    with 'UBR::Geo::Geotransform';   

use MooseX::AttributeShortcuts;
use Modern::Perl;
use UBR::Geo::Types qw(DBICSchema Int);
use UBR::Geo::Helper;
use Data::Dumper;


has 'schema' => (
    is  => 'lazy',
    isa => DBICSchema,
);

has 'map_id' => (
    is => 'ro',
    required => 1,
    isa => Int,
);

sub BUILD {
    my $self = shift;
    
    my @params =  qw(upperleft_x scale_x skew_y upperleft_y skew_x scale_y srid); 
    my $row = $self->schema->resultset('Geotransform')->find($self->map_id);
    my %geotransform = $row->get_columns();
    foreach my $key (@params) {
        $self->$key( $geotransform{$key} );
    };
}

sub _build_schema { UBR::Geo::Helper::get_schema() }

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
