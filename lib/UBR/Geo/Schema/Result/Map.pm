use utf8;
package UBR::Geo::Schema::Result::Map;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

UBR::Geo::Schema::Result::Map

=cut

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 TABLE: C<maps>

=cut

__PACKAGE__->table("maps");

=head1 ACCESSORS

=head2 fid

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'maps_fid_seq'

=head2 boundary_wld

  data_type: 'geometry'
  is_nullable: 1
  size: '4360,15'

=head2 boundary_px

  data_type: 'geometry'
  is_nullable: 1
  size: 8

=head2 filename

  data_type: 'varchar'
  is_nullable: 1
  size: 80

=head2 resolution

  data_type: 'smallint'
  is_nullable: 1

=head2 scale

  data_type: 'double precision'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "fid",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "maps_fid_seq",
  },
  "boundary_wld",
  { data_type => "geometry", is_nullable => 1, size => "4360,15" },
  "boundary_px",
  { data_type => "geometry", is_nullable => 1, size => 8 },
  "filename",
  { data_type => "varchar", is_nullable => 1, size => 80 },
  "resolution",
  { data_type => "smallint", is_nullable => 1 },
  "scale",
  { data_type => "double precision", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</fid>

=back

=cut

__PACKAGE__->set_primary_key("fid");

=head1 UNIQUE CONSTRAINTS

=head2 C<filename>

=over 4

=item * L</filename>

=back

=cut

__PACKAGE__->add_unique_constraint("filename", ["filename"]);


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2015-02-14 16:25:51
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:4dvLgQNzceKWLW7Uz18S/A

use Geo::JSON;
use Geo::JSON::Feature;

sub as_feature_object {
    my $self = shift;

    my $geometry_object = Geo::JSON->from_json(
        $self->get_column('boundary')
    );

    my %properties = map { $_ => $self->get_column($_) }
        $self->non_geometry_columns;

    return Geo::JSON::Feature->new({
        geometry   => $geometry_object,
        properties => \%properties,
    });
}

sub non_geometry_columns {
    my %columns = %{ shift->result_source->columns_info };
    grep { $columns{$_}{data_type} ne 'geometry' } keys(%columns);
}

__PACKAGE__->meta->make_immutable;
1;
