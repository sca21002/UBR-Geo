use utf8;
package UBR::Geo::Schema::ResultSet::YearSeries;

# ABSTRACT: UBR::Geo::Schema::ResultSet::YearSeries
 
use Moose;
use namespace::autoclean;
use MooseX::NonMoose;
    extends 'DBIx::Class::ResultSet';

use Data::Dumper;
 
sub BUILDARGS { $_[2] }

sub maps_per_year {
    my $self = shift;

    return $self->search(
        {},
        {
            select => [
                'me.year',
                { count => 'maps.year' },
            ],
            as => [ qw(year count) ],
            join => 'maps',
            group_by => 'me.year',
            order_by => 'me.year',        
        },
    );
}

__PACKAGE__->meta->make_immutable;
1;
