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

=head1 TABLE: C<maps>

=cut

__PACKAGE__->table("maps");

=head1 ACCESSORS

=head2 map_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'maps_map_id_seq'

=head2 filename

  data_type: 'varchar'
  is_nullable: 1
  size: 80

=head2 boundary_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 resolution

  data_type: 'smallint'
  is_nullable: 1

=head2 mab100

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 mab104

  data_type: 'varchar'
  is_nullable: 1
  size: 50

=head2 mab108

  data_type: 'varchar'
  is_nullable: 1
  size: 50

=head2 mab112

  data_type: 'varchar'
  is_nullable: 1
  size: 50

=head2 mab331

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 scale

  data_type: 'double precision'
  is_nullable: 1

=head2 mab400

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 mab410

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=head2 mab425a

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=head2 year

  data_type: 'varchar'
  is_nullable: 1
  size: 50

=head2 mab451

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 mab590a

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 is_side_map

  data_type: 'smallint'
  is_nullable: 1

=head2 u_mab089

  data_type: 'varchar'
  is_nullable: 1
  size: 50

=head2 u_mab331

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 call_number

  data_type: 'varchar'
  is_nullable: 1
  size: 50

=head2 serial_id

  data_type: 'integer'
  is_nullable: 1

=head2 pid

  data_type: 'integer'
  is_nullable: 1

=head2 pixel_x

  data_type: 'integer'
  is_nullable: 1

=head2 pixel_y

  data_type: 'integer'
  is_nullable: 1

=head2 bvnr

  data_type: 'varchar'
  is_nullable: 1
  size: 11

=head2 project_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 isil

  data_type: 'varchar'
  is_foreign_key: 1
  is_nullable: 1
  size: 16

=cut

__PACKAGE__->add_columns(
  "map_id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "maps_map_id_seq",
  },
  "filename",
  { data_type => "varchar", is_nullable => 1, size => 80 },
  "boundary_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "resolution",
  { data_type => "smallint", is_nullable => 1 },
  "mab100",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "mab104",
  { data_type => "varchar", is_nullable => 1, size => 50 },
  "mab108",
  { data_type => "varchar", is_nullable => 1, size => 50 },
  "mab112",
  { data_type => "varchar", is_nullable => 1, size => 50 },
  "mab331",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "scale",
  { data_type => "double precision", is_nullable => 1 },
  "mab400",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "mab410",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "mab425a",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "year",
  { data_type => "varchar", is_nullable => 1, size => 50 },
  "mab451",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "mab590a",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "is_side_map",
  { data_type => "smallint", is_nullable => 1 },
  "u_mab089",
  { data_type => "varchar", is_nullable => 1, size => 50 },
  "u_mab331",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "call_number",
  { data_type => "varchar", is_nullable => 1, size => 50 },
  "serial_id",
  { data_type => "integer", is_nullable => 1 },
  "pid",
  { data_type => "integer", is_nullable => 1 },
  "pixel_x",
  { data_type => "integer", is_nullable => 1 },
  "pixel_y",
  { data_type => "integer", is_nullable => 1 },
  "bvnr",
  { data_type => "varchar", is_nullable => 1, size => 11 },
  "project_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "isil",
  { data_type => "varchar", is_foreign_key => 1, is_nullable => 1, size => 16 },
);

=head1 PRIMARY KEY

=over 4

=item * L</map_id>

=back

=cut

__PACKAGE__->set_primary_key("map_id");

=head1 UNIQUE CONSTRAINTS

=head2 C<filename>

=over 4

=item * L</filename>

=back

=cut

__PACKAGE__->add_unique_constraint("filename", ["filename"]);

=head1 RELATIONS

=head2 boundary

Type: belongs_to

Related object: L<UBR::Geo::Schema::Result::Boundary>

=cut

__PACKAGE__->belongs_to(
  "boundary",
  "UBR::Geo::Schema::Result::Boundary",
  { fid => "boundary_id" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "RESTRICT",
    on_update     => "CASCADE",
  },
);

=head2 gcps

Type: has_many

Related object: L<UBR::Geo::Schema::Result::GCP>

=cut

__PACKAGE__->has_many(
  "gcps",
  "UBR::Geo::Schema::Result::GCP",
  { "foreign.map_id" => "self.map_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 geotransform

Type: might_have

Related object: L<UBR::Geo::Schema::Result::Geotransform>

=cut

__PACKAGE__->might_have(
  "geotransform",
  "UBR::Geo::Schema::Result::Geotransform",
  { "foreign.map_id" => "self.map_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 isil

Type: belongs_to

Related object: L<UBR::Geo::Schema::Result::Library>

=cut

__PACKAGE__->belongs_to(
  "isil",
  "UBR::Geo::Schema::Result::Library",
  { isil => "isil" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "RESTRICT",
    on_update     => "CASCADE",
  },
);

=head2 project

Type: belongs_to

Related object: L<UBR::Geo::Schema::Result::Project>

=cut

__PACKAGE__->belongs_to(
  "project",
  "UBR::Geo::Schema::Result::Project",
  { id => "project_id" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "RESTRICT",
    on_update     => "CASCADE",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2015-04-28 18:41:08
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:LQZimTOYbe+xeGnnwTNIRQ

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

sub title_isbd {
    my $self = shift;

    # add points as thousands separator
    my $scale = $self->scale;
    $scale =~ s/(^[-+]?\d+?(?=(?>(?:\d{3})+)(?!\d))|\G\d{3}(?=\d))/$1./g;

    my $title_isbd;
    $title_isbd .= $self->mab331 if $self->mab331;
    my $line;
    $line .= $self->mab100 if $self->mab100;
    $line .= ' ; ' if $line and $self->mab104;
    $line .= $self->mab104 if $self->mab104;
    $line .= ' ; ' if $line and $self->mab108;
    $line .= $self->mab108 if $self->mab108;
    $line .= ' ; ' if $line and $self->mab112;
    $line .= $self->mab112 if $self->mab112;
    $line .= ' ; ' if $line and $self->u_mab089;
    $line .= 'Blatt: ' . $self->u_mab089 if $self->u_mab089;
    $line .= ' ; ' if $line and $self->u_mab331;
    $line .= $self->u_mab331 if $self->u_mab331;
    $line .= ' ; ' if $line and $self->mab425a;
    $line .= $self->mab425a if $self->mab425a;
    $line .= ' (' . $self->mab451 . ') ' if $self->mab451;
    $line .= ' ; ' if $line and $line !~ /\)\s*$/ and $self->mab590a;
    $line .= $self->mab590a if $self->mab590a;
    $line .= ' ; ' if $line and $line !~ /\)\s*$/ and $scale;
    $line .= '1:' . $scale if $scale;
    $title_isbd .= '. - ' if $title_isbd and $line;
    $title_isbd .= $line if $line;
    return  $title_isbd;
}

sub exemplar {
    my $self = shift;

    my $library = $self->isil->name;

    my $line .= $library . ' -- ' . $self->call_number;
    return $line;
}

__PACKAGE__->meta->make_immutable;
1;
