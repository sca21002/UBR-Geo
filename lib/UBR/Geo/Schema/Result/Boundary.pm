use utf8;
package UBR::Geo::Schema::Result::Boundary;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

UBR::Geo::Schema::Result::Boundary

=cut

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

=head1 TABLE: C<boundaries>

=cut

__PACKAGE__->table("boundaries");

=head1 ACCESSORS

=head2 fid

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'boundaries_fid_seq'

=head2 boundary_wld

  data_type: 'geometry'
  is_nullable: 1
  size: '4372,15'

=head2 boundary_px

  data_type: 'geometry'
  is_nullable: 1
  size: 20

=cut

__PACKAGE__->add_columns(
  "fid",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "boundaries_fid_seq",
  },
  "boundary_wld",
  { data_type => "geometry", is_nullable => 1, size => "4372,15" },
  "boundary_px",
  { data_type => "geometry", is_nullable => 1, size => 20 },
);

=head1 PRIMARY KEY

=over 4

=item * L</fid>

=back

=cut

__PACKAGE__->set_primary_key("fid");

=head1 RELATIONS

=head2 maps

Type: has_many

Related object: L<UBR::Geo::Schema::Result::Map>

=cut

__PACKAGE__->has_many(
  "maps",
  "UBR::Geo::Schema::Result::Map",
  { "foreign.boundary_id" => "self.fid" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2015-02-28 20:39:17
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:m9xBVtvzc8P7MHqFFCHPQg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
