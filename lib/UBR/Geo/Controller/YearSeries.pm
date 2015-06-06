use utf8;
package UBR::Geo::Controller::YearSeries;

# ABSTRACT: Controller for statistics of maps per year 

use Moose;
use namespace::autoclean;
use Data::Dumper;
use JSON;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

UBR::Geo::Controller::YearSeries Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


sub statistics : Chained('/base') PathPart('statistics') CaptureArgs(0) { }

sub maps_per_year :  Chained('statistics') PathPart('maps-per-year') Args(0) {
    my ($self, $c) = @_; 
    my $maps_per_year = $c->model('UBR::GeoDB::YearSeries')->maps_per_year();
    
    my @rows;
    while (my $row = $maps_per_year->next) {
        my $href = { $row->get_columns() };
        push @rows, $href; 
    }    
 
    my $response->{data} = \@rows;

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
