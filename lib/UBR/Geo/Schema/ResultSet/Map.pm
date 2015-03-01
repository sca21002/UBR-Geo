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
    my ($self, $cond, $attrs) = @_;

    warn "Cond: ", Dumper $cond;
    warn "Attr: ", Dumper $attrs;

    my $xmin = delete $cond->{xmin};
    my $ymin = delete $cond->{ymin};
    my $xmax = delete $cond->{xmax};
    my $ymax = delete $cond->{ymax};
    my $srt  = 4326; 

    my $envelope   = 'ST_Transform(ST_MakeEnvelope(?, ?, ?, ?, ?), 3857)';
    my $area_query = 'ST_Area(ST_Intersection(boundary.boundary_wld, ' . $envelope . '))';

    $attrs = {
    	%$attrs,
        join   => [ 'boundary' ],
        select => [ qw( map_id filename scale ), 
        ], 
        as     => [ qw( map_id filename scale ) ],
        order_by => { -desc => \[
            $area_query . ' / scale ^ 2',
            $xmin, $ymin, $xmax, $ymax, $srt
        ]},      
        
    };

    return $self->search({
        -and => [
        \[
            $area_query . ' > 0',
            $xmin, $ymin, $xmax, $ymax, $srt
         ],
         scale => { '>' => 0 },
        ]}, 
        $attrs,
    );
}

sub find_with_geojson {
    my $self = shift;
    my $map_id = shift;


    return $self->search(
        {
	    map_id => $map_id,
        },
        {
            join      => [ 'boundary' ],
            '+select' => \'ST_AsGeoJSON(ST_Transform(boundary.boundary_wld,\'4326\'))',
            '+as'     => 'boundary',
        },
    )->first;
}
