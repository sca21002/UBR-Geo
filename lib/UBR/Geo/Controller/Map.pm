use utf8;
package UBR::Geo::Controller::Map;

# ABSTRACT: Controller for searching and listing maps 

use Moose;
use namespace::autoclean;
use Data::Dumper;

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

    my $bbox = $c->req->params->{bbox};
    $c->log->debug('BBox: ' . $bbox);
    my ($xmin, $ymin, $xmax, $ymax) = split(',', $bbox);

    #my $xmin = 8.98;
    #my $ymin = 47.27;
    #my $xmax = 13.83;
    #my $ymax = 50.56;

    my $page = $c->req->params->{page} || 1; 
    $c->log->debug("Page: $page");
    my $entries_per_page = 5;

    my $map_rs = $c->stash->{map_rs}->intersects_with_bbox(
	{ 
	    xmin => $xmin, 
            ymin => $ymin, 
            xmax => $xmax,
            ymax =>  $ymax,
        },
        {
            page => $page,
            rows => $entries_per_page,
            
        },
    );
    my @rows;
    while (my $row = $map_rs->next) {
        my $href = { $row->get_columns() };
        $href->{scale} =~ s/(^[-+]?\d+?(?=(?>(?:\d{3})+)(?!\d))|\G\d{3}(?=\d))/$1./g;
        $href->{scale} = '1 : ' . $href->{scale} if $href->{scale};  
        push @rows, $href; 
    }    
 
    my $response->{maps} = \@rows;

    $response->{page}    = $page;
    #$response->{total}   = $map_rs->pager->last_page;
    $response->{maps_total} = $map_rs->pager->total_entries;
   
    $c->log->debug('Total entries: ', $response->{maps_total});

    $c->stash(
        %$response,
        current_view => 'JSON'
    );
}

sub map : Chained('maps') PathPart('') CaptureArgs(1) {
    my ($self, $c, $map_id) = @_;

    my $rs = $c->stash->{map_rs}; 
    my $map = $rs->find_with_geojson($map_id) 
	|| $c->detach('not_found');
    $c->stash->{map} = $map;
}

sub boundary : Chained('map') PathPart('boundary') Args(0) {
    my ($self, $c) = @_;

    my $feature = $c->stash->{map}->as_feature_object;
    $c->log->debug($feature);
    $c->stash(
        feature => $feature,
        current_view => 'GeoJSON',
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
