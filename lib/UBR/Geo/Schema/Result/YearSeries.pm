use utf8;
package UBR::Geo::Schema::Result::YearSeries;
 
use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';
 
__PACKAGE__->table_class('DBIx::Class::ResultSource::View');
 
__PACKAGE__->table('yearseries');
__PACKAGE__->result_source_instance->is_virtual(1);
__PACKAGE__->result_source_instance->view_definition(
    "SELECT generate_series(1523,1950) AS year"
);

__PACKAGE__->add_columns(
  'year' => {
    data_type => 'integer',
  },
);


__PACKAGE__->has_many(
    "maps",
    "UBR::Geo::Schema::Result::Map",
    { "foreign.year" => "self.year" },
    { 
        join_type => 'LEFT',
        cascade_copy => 0, 
        cascade_delete => 0 
    },
);

__PACKAGE__->meta->make_immutable;
1;
