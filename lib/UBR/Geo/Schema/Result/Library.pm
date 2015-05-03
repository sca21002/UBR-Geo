use utf8;
package UBR::Geo::Schema::Result::Library;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

UBR::Geo::Schema::Result::Library

=cut

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

=head1 TABLE: C<libraries>

=cut

__PACKAGE__->table("libraries");

=head1 ACCESSORS

=head2 isil

  data_type: 'varchar'
  is_nullable: 0
  size: 16

=head2 name

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 info

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "isil",
  { data_type => "varchar", is_nullable => 0, size => 16 },
  "name",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "info",
  { data_type => "text", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</isil>

=back

=cut

__PACKAGE__->set_primary_key("isil");

=head1 RELATIONS

=head2 maps

Type: has_many

Related object: L<UBR::Geo::Schema::Result::Map>

=cut

__PACKAGE__->has_many(
  "maps",
  "UBR::Geo::Schema::Result::Map",
  { "foreign.isil" => "self.isil" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2015-04-28 18:41:08
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:9dx4NMsIU2VMnaEaQwusjQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
