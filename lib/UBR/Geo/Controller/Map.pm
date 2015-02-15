use utf8;
package UBR::Geo::Controller::Map;

# ABSTRACT: Controller for searching and listing maps 

use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

UBR::Geo::Controller::Map - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub maps : Chained('/base') PathPart('maps') Args(0) {
    my ($self, $c) = @_;

    my $xmin = 8.98;
    my $ymin = 47.27;
    my $xmax = 13.83;
    my $ymax = 50.56;
    
    my $rs = $c->model('UBR::GeoDB::Map')->intersects_with_bbox(
    	$xmin, $ymin, $xmax, $ymax,
    );
    my @rows;
    while (my $row = $rs->next) {
        my $href = { $row->get_columns() };
        $href->{scale} =~ s/(^[-+]?\d+?(?=(?>(?:\d{3})+)(?!\d))|\G\d{3}(?=\d))/$1./g;
        $href->{scale} = '1 : ' . $href->{scale} if $href->{scale};  
        push @rows, $href; 
    }    
 
    my $response->{maps} = \@rows;
    $response->{maps_total} = scalar @rows;

    $c->stash(
        %$response,
        current_view => 'JSON'
    );
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
