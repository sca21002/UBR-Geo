use utf8;
package UBR::Geo::Schema::Result::Worldfile;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

UBR::Geo::Schema::Result::Worldfile

=cut

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

=head1 TABLE: C<worldfiles>

=cut

__PACKAGE__->table("worldfiles");

=head1 ACCESSORS

=head2 worldfile_id

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 x_scale

  data_type: 'double precision'
  is_nullable: 1

=head2 y_skew

  data_type: 'double precision'
  is_nullable: 1

=head2 x_skew

  data_type: 'double precision'
  is_nullable: 1

=head2 y_scale

  data_type: 'double precision'
  is_nullable: 1

=head2 map_left

  data_type: 'double precision'
  is_nullable: 1

=head2 map_top

  data_type: 'double precision'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "worldfile_id",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "x_scale",
  { data_type => "double precision", is_nullable => 1 },
  "y_skew",
  { data_type => "double precision", is_nullable => 1 },
  "x_skew",
  { data_type => "double precision", is_nullable => 1 },
  "y_scale",
  { data_type => "double precision", is_nullable => 1 },
  "map_left",
  { data_type => "double precision", is_nullable => 1 },
  "map_top",
  { data_type => "double precision", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</worldfile_id>

=back

=cut

__PACKAGE__->set_primary_key("worldfile_id");


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2015-02-28 20:39:17
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:iA3ucyZuFhv8nd4MOXiOWQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
