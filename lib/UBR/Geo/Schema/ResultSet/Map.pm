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

    my $xmin = delete $cond->{xmin};
    my $ymin = delete $cond->{ymin};
    my $xmax = delete $cond->{xmax};
    my $ymax = delete $cond->{ymax};
    my $project = delete $cond->{project};
    delete $cond->{isil} unless $cond->{isil};  # only if valid isil
    my $srt  = 4326; 

    my $envelope   = 'ST_Transform(ST_MakeEnvelope(?, ?, ?, ?, ?), 3857)';
    my $area_intsec 
        = 'ST_Area(ST_Intersection(boundary.boundary_wld, ' . $envelope . '))';
    my $area_intsec_sqr = $area_intsec . ' ^ 3';
    my $area_query = "ST_Area(ST_Transform(ST_MakeEnvelope(?,$ymin,$xmax,$ymax,$srt),3857)) ^ 2";

    my $join = [ 'boundary' ];
    if ($project) {
        push @$join, 'project' if $project;
        $cond = { %$cond, 'project.short' => $project };
    }


    $attrs = {} unless ref $attrs eq 'HASH';
    $attrs = {
    	%$attrs,
        join   => $join,
#        select => [ qw( map_id mab331 mab425a call_number filename scale pid ), 
#        ], 
#        as     => [ qw( map_id title year call_number filename scale pid ) ],
        order_by => { -desc => \[
            $area_intsec_sqr 
            . ' / ' . $area_query .' / scale ^ 2',
            $xmin, $ymin, $xmax, $ymax, $srt, $xmin
        ]},      
        
    };

    return $self->search({
        -and => [
        \[
            $area_intsec . ' > 0',
            $xmin, $ymin, $xmax, $ymax, $srt
         ],
         scale => { '>' => 0 },
         # fid   => { '<' => 954 },
         # filename => { 'like' => 'ubr05510%' },
         $cond,
        ]}, 
        $attrs,
    );
}

sub _cross {
    my $columns = shift || [];
    my $tokens  = shift || [];
    map {s/%/\\%/g} @$tokens;
    
    my @result;
    foreach my $token (@$tokens) {
        push @result, [ map +{ $_ => {like => "%$token%"} }, @$columns ];    
    }
    return @result;
}

sub filter {
    my ($self, $searchstr) = @_;

    my @columns = qw( 
        mab100 mab104 mab108 mab112 mab331 mab400 mab410 mab451 mab590a 
        u_mab089 u_mab331 call_number bvnr
    );
    my @tokens = split /\s+/, $searchstr;
    my @conds = _cross(\@columns, \@tokens);
 
    return $self->search( { -and => \@conds } );
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

sub contains_point {
    my ($self, $map_id, $lon, $lat) = @_; 

    my $contains = sprintf(
        "ST_CONTAINS(boundary.boundary_wld,ST_SetSRID(ST_Point(%f,%f),3857))",
        $lon, $lat
    );

    return $self->search(
        {
            map_id => $map_id,
        },
        {
            join      => [ 'boundary' ],
            'select' => \$contains,
            'as'     => 'contains',
            
        }
    )->first;
}

sub maps_per_year {
    my ($self, $cond, $attrs) = @_;

    my $xmin = delete $cond->{xmin};
    my $ymin = delete $cond->{ymin};
    my $xmax = delete $cond->{xmax};
    my $ymax = delete $cond->{ymax};
    my $project = delete $cond->{project};
    delete $cond->{isil} unless $cond->{isil};
    my $srt  = 4326; 

    my $envelope   = 'ST_Transform(ST_MakeEnvelope(?, ?, ?, ?, ?), 3857)';
    my $area_intsec 
        = 'ST_Area(ST_Intersection(boundary.boundary_wld, ' . $envelope . '))';

    my $join = [ 'boundary' ];
    if ($project) {
        push @$join, 'project' if $project;
        $cond = { %$cond, 'project.short' => $project };
    }

    $attrs = {} unless ref $attrs eq 'HASH';
    $attrs = {
    	%$attrs,
        join   => $join,
        select => [
            'year',
            {count => 'year'},
        ],
        as     => [qw(year count)],
        group_by => 'year',
        order_by => 'year',        
    };


    return $self->search({
        -and => [
        \[
            $area_intsec . ' > 0',
            $xmin, $ymin, $xmax, $ymax, $srt
         ],
         scale => { '>' => 0 },
         year  => { '!=' => undef },
         $cond,
        ]}, 
        $attrs,
    );
}

__PACKAGE__->meta->make_immutable;
1;

