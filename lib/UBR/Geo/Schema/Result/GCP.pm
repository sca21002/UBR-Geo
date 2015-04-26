use utf8;
package UBR::Geo::Schema::Result::GCP;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

UBR::Geo::Schema::Result::GCP

=cut

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

=head1 TABLE: C<gcps>

=cut

__PACKAGE__->table("gcps");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'gcps_id_seq'

=head2 map_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 x

  data_type: 'double precision'
  is_nullable: 1

=head2 y

  data_type: 'double precision'
  is_nullable: 1

=head2 z

  data_type: 'double precision'
  is_nullable: 1

=head2 pixel

  data_type: 'double precision'
  is_nullable: 1

=head2 line

  data_type: 'double precision'
  is_nullable: 1

=head2 info

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 srid

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "gcps_id_seq",
  },
  "map_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "x",
  { data_type => "double precision", is_nullable => 1 },
  "y",
  { data_type => "double precision", is_nullable => 1 },
  "z",
  { data_type => "double precision", is_nullable => 1 },
  "pixel",
  { data_type => "double precision", is_nullable => 1 },
  "line",
  { data_type => "double precision", is_nullable => 1 },
  "info",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "srid",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 map

Type: belongs_to

Related object: L<UBR::Geo::Schema::Result::Map>

=cut

__PACKAGE__->belongs_to(
  "map",
  "UBR::Geo::Schema::Result::Map",
  { map_id => "map_id" },
  { is_deferrable => 0, on_delete => "RESTRICT", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2015-04-03 10:17:21
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:hJjMAKCuoLuZs3oOs0gllg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
