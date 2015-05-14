#!/usr/bin/env perl
use utf8;
use Carp;
use Config::ZOMG;
use Data::Dumper;
use FindBin qw($Bin);
use Path::Tiny;
use lib path($Bin)->parent(2)->child('lib')->stringify;
use English qw( -no_match_vars );   # Avoids regex performance penalty
use Modern::Perl;
use Getopt::Long;
use Pod::Usage;
use Log::Log4perl qw(:easy);
use Getopt::Long;
use UBR::Geo::Helper;
use UBR::Geo::GCP::FromDB;
use UBR::Geo::Geotransform::FromGCP;

my $logfile = path($Bin)->parent(2)->child(
    'geotransform_from_gcps.log'
);

### initialise log file
Log::Log4perl->easy_init(
    { level   => $DEBUG,
      file    => ">" . $logfile,
    },
    { level   => $TRACE,
      file    => 'STDOUT',
    },
);

### get options

my ($opt_help, $opt_man);

GetOptions (
    'help!'        => \$opt_help,
    'man!'         => \$opt_man,
) or pod2usage( "Try '$PROGRAM_NAME --help' for more information." );

pod2usage( -verbose => 1 ) if $opt_help;
pod2usage( -verbose => 2 ) if $opt_man;

my $schema = UBR::Geo::Helper::get_schema();

my $gcp_group_rs = $schema->resultset('GCP')->search(
    {
#        'geotransforms.map_id' => undef,    
    },
    {
        columns => [ qw(map.map_id map.filename) ],
        join => { map => 'geotransform' },
        group_by => [ qw(map.map_id) ],
    }
);

my $geotransform_rs = $schema->resultset('Geotransform');

while (my $gcp_group = $gcp_group_rs->next) {
    my $filename = $gcp_group->map->filename;
    my $map_id   = $gcp_group->map->map_id;
    INFO("Working on '$filename'");
    my $gcp = UBR::Geo::GCP::FromDB ->new(
	    filename => $filename,
    );
    my $geotransform = UBR::Geo::Geotransform::FromGCP->new({gcp => $gcp});
    say Dumper( { %{$geotransform->as_href}, map_id => $map_id } );
    $geotransform_rs->create({ 
        %{$geotransform->as_href},
        map_id => $map_id,
    });
}

=encoding utf-8

=head1 NAME
 
geotransform_from_gcps.pl - transformation coefficients from gcps   

=head1 SYNOPSIS

geotransform_from_gcps.pl [options]  

 Options:
   --help         display this help and exit
   --man          display extensive help


 Examples:
   geotransform_from_gcps.pl --order_id ubr15411 --tiff_dir ubr15411/mst/tif   
   geotransform_from_gcps.pl --help
   geotransform_from_gcps.pl --man 
   

=head1 DESCRIPTION

Calculate affine transformation coefficients from groundcontrol points

Database is searched for gcps without corresponding transformations.
Coefficients for affine transformation matrix is calculated from ground
control points.

=head1 AUTHOR

Albert Schröder <albert.schroeder@ur.de>

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

