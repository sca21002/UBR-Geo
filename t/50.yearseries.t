use utf8;
use strict;
use warnings;
use FindBin qw($Bin);
use Path::Tiny;
use lib path($Bin)->parent->child('lib')->stringify;
use Test::More;
use Data::Dumper;

BEGIN {
    use_ok('UBR::Geo::Helper') or exit;
}

my $schema = UBR::Geo::Helper::get_schema();

my $count = $schema->resultset('YearSeries')->count;

is ($count, 428, '1523 .. 1950');

my $rs = $schema->resultset('YearSeries')->search(
    {
    },
    {
        select => [
            'me.year',
            {count => 'maps.year'},
        ],
        as => [ qw(year count)],
        join => 'maps',
        group_by => 'me.year',
        order_by => 'me.year',        
    },
);

while (my $row = $rs->next) {
   diag $row->year, " ",  $row->get_column('count');

}



done_testing();
