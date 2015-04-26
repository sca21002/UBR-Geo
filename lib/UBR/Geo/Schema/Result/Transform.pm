use utf8;
package UBR::Geo::Schema::Result::Transform;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

UBR::Geo::Schema::Result::Transform

=cut

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

=head1 TABLE: C<transforms>

=cut

__PACKAGE__->table("transforms");

=head1 ACCESSORS

=head2 map_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 upperleft_x

  data_type: 'double precision'
  is_nullable: 1

=head2 scale_x

  data_type: 'double precision'
  is_nullable: 1

=head2 skew_y

  data_type: 'double precision'
  is_nullable: 1

=head2 upperleft_y

  data_type: 'double precision'
  is_nullable: 1

=head2 skew_x

  data_type: 'double precision'
  is_nullable: 1

=head2 scale_y

  data_type: 'double precision'
  is_nullable: 1

=head2 srid

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "map_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "upperleft_x",
  { data_type => "double precision", is_nullable => 1 },
  "scale_x",
  { data_type => "double precision", is_nullable => 1 },
  "skew_y",
  { data_type => "double precision", is_nullable => 1 },
  "upperleft_y",
  { data_type => "double precision", is_nullable => 1 },
  "skew_x",
  { data_type => "double precision", is_nullable => 1 },
  "scale_y",
  { data_type => "double precision", is_nullable => 1 },
  "srid",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);

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


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2015-04-04 19:22:00
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:scOqby9y1LCBYlOp9CE8wQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
