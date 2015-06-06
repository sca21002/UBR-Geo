use utf8;
package UBR::Geo::View::JSON;

# ABSTRACT: Catalyst JSON View

use strict;
use base 'Catalyst::View::JSON';

__PACKAGE__->config({
    expose_stash => [ qw(
        maps maps_total page pixel detail contains data
    ) ],
});

=head1 NAME

UBR::Geo::View::JSON - Catalyst JSON View

=head1 SYNOPSIS

See L<UBR::Geo>

=head1 DESCRIPTION

Catalyst JSON View.

=head1 AUTHOR

GIS user,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
