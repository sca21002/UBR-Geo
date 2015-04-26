#!/usr/bin/env perl
use utf8;
use Path::Tiny;
use FindBin qw($Bin);
use lib path($Bin)->parent(2)->child(lib)->stringify;
use Data::Dumper;
use BVB::DigiTool;
use Modern::Perl;
use Log::Log4perl qw(:easy);
use UBR::Geo::Helper;

my $logfile = path($Bin)->parent(1)->child('add_pid.log');

### initialise log file
Log::Log4perl->easy_init(
    { level   => $DEBUG,
      file    => ">" . $logfile,
    },
    { level   => $TRACE,
      file    => 'STDOUT',
    },
);

my $schema = UBR::Geo::Helper::get_schema();

my $maps = $schema->resultset('Map')->search({
        pid => undef,
        filename => { like => 'ubr%' },
   });

my $count = $maps->count;

INFO("$count maps without a pid");


my $digitool = BVB::DigiTool->new();
while (my $map = $maps->next) {
    my $filename = $map->filename;
    my $pid = $digitool->get_pid($filename);
    INFO("$filename --> $pid");
    if ($pid) {
        $map->update({pid => $pid});
    }    
}


=encoding utf-8

=head1 NAME
 
add_pid.pl - add PIDs (DigiTool ids) to map rows  

=head1 SYNOPSIS

add_pid.pl 

=head1 DESCRIPTION

Fetches DigiTool IDs (pid) from digitool server

Searches for missing pids in the table maps and tries to fetch these from
the digitool server. If found the pid is added in the database for this map.

=head1 AUTHOR

Albert Schröder <albert.schroeder@ur.de>

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
