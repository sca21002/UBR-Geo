use utf8;
package UBR::Geo::Controller::Map;

# ABSTRACT: Controller for searching and listing maps 

use Moose;
use namespace::autoclean;
use Data::Dumper;
use UBR::Geo::Geotransform::Simple;
use JSON;
use Try::Tiny;
use DBIx::Class::ResultClass::HashRefInflator;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

UBR::Geo::Controller::Map - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub maps: Chained('/base') PathPart('map') CaptureArgs(0) {
    my ($self, $c) = @_;
    
    $c->stash->{map_rs} = $c->model('UBR::GeoDB::Map');
}


sub list : Chained('maps') PathPart('list') Args(0) {
    my ($self, $c) = @_;

    my $bbox = $c->req->params->{bbox} || '8.98,47.27,13.83,50.56';
    my $isil = $c->req->params->{isil};
    my $project = $c->req->params->{project}; 
    my $year_min = $c->req->params->{year_min};
    my $year_max = $c->req->params->{year_max};

    $c->log->debug('BBox: ' . $bbox);
    my ($xmin, $ymin, $xmax, $ymax) = split(',', $bbox);

    my $page = $c->req->params->{page} || 1; 
    $c->log->debug("Page: $page");
    my $entries_per_page = 5;

    my $cond = {
        xmin    => $xmin, 
        ymin    => $ymin, 
        xmax    => $xmax,
        ymax    => $ymax,
        isil    => $isil,
        project => $project,
    };
    push @{$cond->{'-and'}}, { year => { '>=' => $year_min } } if $year_min;
    push @{$cond->{'-and'}}, { year => { '<=' => $year_max } } if $year_max;

    my $map_rs = $c->stash->{map_rs}->intersects_with_bbox(
        $cond,
        {
            page => $page,
            rows => $entries_per_page,
            
        },
    );

    my @maps_per_year = $c->stash->{map_rs}->maps_per_year(
	    { 
	        xmin    => $xmin, 
            ymin    => $ymin, 
            xmax    => $xmax,
            ymax    => $ymax,
            isil    => $isil,
            project => $project,
        },
        { result_class => 'DBIx::Class::ResultClass::HashRefInflator' }
    )->all;

    foreach my $year (@maps_per_year) {
        $year->{count} += 0;
        $c->log->croak('Year is undefinded') unless defined $year->{year};
    }

    my $response->{maps_per_year} = [ @maps_per_year ];

    my @rows;
    while (my $row = $map_rs->next) {
        my $href = { $row->get_columns() };
        $href->{scale} =~ s/(^[-+]?\d+?(?=(?>(?:\d{3})+)(?!\d))|\G\d{3}(?=\d))/$1./g;
        $href->{scale} = '1 : ' . $href->{scale} if $href->{scale};  
        $href->{isbd} = $row->title_isbd;
        push @rows, $href; 
    }    
 
    $response->{maps} = \@rows;

    $response->{page}    = $page;
    #$response->{total}   = $map_rs->pager->last_page;
    $response->{maps_total} = $map_rs->pager->total_entries;
   
    $c->log->debug('Total entries: ', $response->{maps_total});

    $c->stash(
        %$response,
        current_view => 'JSON'
    );
}


sub map_with_geojson : Chained('maps') PathPart('') CaptureArgs(1) {
    my ($self, $c, $map_id) = @_;

    my $rs = $c->stash->{map_rs}; 
    my $map = $rs->find_with_geojson($map_id) 
	|| $c->detach('not_found');
    $c->stash->{map} = $map;
}


sub boundary : Chained('map_with_geojson') PathPart('boundary') Args(0) {
    my ($self, $c) = @_;

    my $feature = $c->stash->{map}->as_feature_object;
    $c->log->debug($feature);
    $c->stash(
        feature => $feature,
        current_view => 'GeoJSON',
    );
}



sub map : Chained('maps') PathPart('') CaptureArgs(1) {
    my ($self, $c, $map_id) = @_;

    my $rs = $c->stash->{map_rs}; 
    my $map = $rs->find($map_id) 
	|| $c->detach('not_found');
    $c->stash->{map} = $map;
}

sub detail : Chained('map') PathPart('detail') Args(0) {
    my ($self, $c) = @_;

    my $map = $c->stash->{map};
    my $href = { $map->get_columns() };
    $href->{isbd} = $map->title_isbd;
    $href->{exemplar} = $map->exemplar;

    my $response = { detail => $href };
    $c->stash(
        %$response,
        current_view => 'JSON'
    );
}

sub geotransform : Chained('map') PathPart('geotransform') Args(0) {
    my ($self, $c) = @_;

    my $x_geo = $c->req->params->{x};
    my $y_geo = $c->req->params->{y};
    my $invers = $c->req->params->{invers};
    my $srid   = $c->req->params->{srid} || 3857; 

    unless (
        defined $x_geo 
        && defined $y_geo
        && $invers 
    ) {
	    $c->detach('not_found');
    }

    my $map = $c->stash->{map};
    my $geotransform_row = $map->geotransform;    
    my $geotransform = UBR::Geo::Geotransform::Simple->new(
        $geotransform_row->get_columns()
    );

    $c->log->debug("Transform: $x_geo, $y_geo, $srid");
    my ($x_px, $y_px) 
        = $geotransform->transform_invers($x_geo, $y_geo, $srid);
    $x_px = sprintf("%.0f",$x_px);
    $y_px = sprintf("%.0f",$y_px);

    my $response = { pixel => [$x_px, $y_px]  };
    $c->stash(
        %$response,
        current_view => 'JSON'
    );
}

# TODO: is a test for 4 coords, should be unified with geotransform
sub geotransform2 : Chained('map') PathPart('geotransform2') Args(0) {
    my ($self, $c) = @_;

    my $x1_geo = $c->req->params->{x1};
    my $y1_geo = $c->req->params->{y1};
    my $x2_geo = $c->req->params->{x2};
    my $y2_geo = $c->req->params->{y2};
    my $invers = $c->req->params->{invers};
    my $srid   = $c->req->params->{srid} || 3857; 

    unless (
        defined $x1_geo && defined $y1_geo && defined $x2_geo && defined $y2_geo
        && $invers 
    ) {
	    $c->detach('not_found');
    }

    my $map = $c->stash->{map};
    my $geotransform_row = $map->geotransform;    
    my $geotransform = UBR::Geo::Geotransform::Simple->new(
        $geotransform_row->get_columns()
    );

    $c->log->debug("Transform: $x1_geo, $y1_geo, $x2_geo, $y2_geo, $srid");
    my ($x1_px, $y1_px);
    try {
        ($x1_px, $y1_px)
        = $geotransform->transform_invers($x1_geo, $y1_geo, $srid);
    } catch {
        $c->log->debug("Transform failed: $_");
	    $c->detach('not_found');
    };
    $x1_px = sprintf("%.0f",$x1_px);
    $y1_px = sprintf("%.0f",$y1_px);
    my ($x2_px, $y2_px);
    try {
        ($x2_px, $y2_px) 
            = $geotransform->transform_invers($x2_geo, $y2_geo, $srid);
    } catch {
        $c->log->debug("Transform failed: $_");
	    $c->detach('not_found');
    };
    $x2_px = sprintf("%.0f",$x2_px);
    $y2_px = sprintf("%.0f",$y2_px);

    my $response = { pixel => [$x1_px, $y1_px, $x2_px, $y2_px]  };
    $c->stash(
        %$response,
        current_view => 'JSON'
    );
}

sub map_with_contains : Chained('maps') PathPart('') CaptureArgs(1) {
    my ($self, $c, $map_id) = @_;

    $c->stash->{map_id} = $map_id;
}

sub contains_point : Chained('map_with_contains') PathPart('contains') Args(0) {
    my ($self, $c) = @_;

    my $map_id = $c->stash->{map_id};
    my $rs = $c->stash->{map_rs}; 

    my $lon = $c->req->params->{x};
    my $lat = $c->req->params->{y};

    unless ( defined $lon && defined $lat && $map_id ) {
	    $c->detach('not_found');
    }

    my $row = $rs->contains_point($map_id, $lon, $lat);

    my $contains = $row->get_column('contains');
    $c->log->debug('Contains: ', $contains);
    my $response = { contains => $contains ? JSON::true : JSON::false };
    $c->stash(
        %$response,
        current_view => 'JSON'
    );
}

sub not_found : Local {
    my ($self, $c) = @_;
    $c->response->status(404);
    $c->stash->{error_msg} = "Map not found!";
    $c->detach('list');
}



=encoding utf8

=head1 AUTHOR

GIS user,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
