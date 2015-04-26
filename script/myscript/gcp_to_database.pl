#!/usr/bin/env perl
use utf8;
use Path::Tiny;
use FindBin qw($Bin);
use lib path($Bin)->parent(2)->child(lib)->stringify;
use Data::Dumper;
use English qw( -no_match_vars );   # Avoids regex performance penalty
use Modern::Perl;
use Getopt::Long;
use Log::Log4perl qw(:easy);
use Pod::Usage;
#use UBR::Geo::OGR::DataSource::Pg;
use UBR::Geo::GCP::FromFile;
use UBR::Geo::Helper;
# use Geo::OSR;

my $logfile = path($Bin)->parent(2)->child('gcp_to_database.log');

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

my ($gcp_dir, $srs, $opt_help, $opt_man);

GetOptions (
    "gcp_dir=s"    => \$gcp_dir,
    "srs=s"        => \$srs,
    'help!'        => \$opt_help,
    'man!'         => \$opt_man,
) or pod2usage( "Try '$PROGRAM_NAME --help' for more information." );

pod2usage( -verbose => 1 ) if $opt_help;
pod2usage( -verbose => 2 ) if $opt_man;

pod2usage( -verbose => 1 ) unless $gcp_dir && $srs;


$gcp_dir  = path($gcp_dir);

INFO('Groundcontrolpoint dir: ' . $gcp_dir);
INFO('Projection:             ' . $srs);

LOGCROAK("Directory of groundcontrolpoints doesn't exist")
    unless $gcp_dir->is_dir;

my @gcp_files = path($gcp_dir)->children( qr/\..{3}\.points$/ );

INFO(scalar @gcp_files, " groundcontrolpoint files found");

my $schema = UBR::Geo::Helper::get_schema();

foreach my $gcp_file (sort @gcp_files) {
    INFO("Working  $gcp_file");
    my $gcp = UBR::Geo::GCP::FromFile->new( file => $gcp_file );
    my ($filename) = $gcp_file->basename =~ qr/([^.]*)\..{3}\.points$/;
    write_gcps($filename, $schema, $gcp, $srs); 
    #last;
}


sub write_gcps {
    my ($filename, $schema, $gcp, $srs) = @_; 

    INFO("Filename: '$filename'");
    my $map = $schema->resultset('Map')->search({
            filename => $filename,
    })->first;        
    INFO("Map_id: '" . $map->map_id ."'");
    my $column = $gcp->gcps_as_href;
    @$column =  map {
        delete $_->{id};            # remove column id
        +{ %$_, 
           map_id => $map->map_id,  # add column map_id       
           srid   => $srs,          # add column srid (spatial ref)  
        }
    } @$column; 
    #say Dumper($column);
    $schema->resultset('GCP')->populate($column);
}


=encoding utf-8

=head1 NAME
 
gcp_to_database.pl - save gcps into database  

=head1 SYNOPSIS

gcp_to_database.pl [options]  

 Options:
   --help         display this help and exit
   --man          display extensive help

   --gcp_dir      directory of files with ground control points (GCPs)
   --srs          spatial reference system (SRS)

 Examples:
   gcp_to_database.pl --gcp_dir t/input_files --srs 3857  
   gcp_to_database.pl --help
   gcp_to_database.pl --man 
   

=head1 DESCRIPTION

Save gcps into database  

=head1 AUTHOR

Albert Schröder <albert.schroeder@ur.de>

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
