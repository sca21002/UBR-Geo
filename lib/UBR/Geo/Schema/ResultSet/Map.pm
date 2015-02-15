use utf8;
package UBR::Geo::Schema::ResultSet::Map;

# ABSTRACT: UBR::Geo::Schema::ResultSet::Map
 
use Moose;
use namespace::autoclean;
use MooseX::NonMoose;
    extends 'DBIx::Class::ResultSet';

use Data::Dumper;
 
sub BUILDARGS { $_[2] }

sub intersects_with_bbox {
    my $self = shift;
    my $cond = shift || {};

    # my ($xmin, $ymin, $xmax,  $ymax) = @_; 
    my $srt  = 4326; 
    my ($xmin, $ymin, $xmax,  $ymax)  = (8.98,47.27,13.83,50.56);

    my $envelope   = 'ST_Transform(ST_MakeEnvelope(?, ?, ?, ?, ?), 3857)';
    my $area_query = 'ST_Area(ST_Intersection(boundary_wld, ' . $envelope . '))';

    return $self->search(
        \[
            $area_query . ' > 0',
            $xmin, $ymin, $xmax, $ymax, $srt
         ],
        {   
            select => [ qw( filename scale ), 
            ], 
            as     => [ qw( filename scale ) ],
            order_by => { -desc => \[
                $area_query . ' / scale ^ 2',
                $xmin, $ymin, $xmax, $ymax, $srt
            ]},      
        },
    );
}
