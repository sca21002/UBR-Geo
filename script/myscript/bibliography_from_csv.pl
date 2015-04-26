#!/usr/bin/env perl
use utf8;
use Path::Tiny;
use FindBin qw($Bin);
use lib path($Bin)->parent(2)->child('lib')->stringify;
use Text::CSV_XS;
use Log::Log4perl qw(:easy);
use Modern::Perl;
use UBR::Geo::Helper;
use English qw( -no_match_vars );   # Avoids regex performance penalty
use Pod::Usage;
use Getopt::Long;
use Data::Dumper;

binmode(STDOUT, ":utf8");

my $logfile = path($Bin)->parent(2)->child('bibliography_from_csv.log');

### Logdatei initialisieren
Log::Log4perl->easy_init(
    { level   => $DEBUG,
      file    => ">" . $logfile,
    },
    { level   => $TRACE,
      file    => 'STDOUT',
    },
);

### get options

my ($csv_file, $opt_help, $opt_man);

GetOptions (
    "csv=s"    => \$csv_file,
    'help!'    => \$opt_help,
    'man!'     => \$opt_man,
) or pod2usage( "Try '$PROGRAM_NAME --help' for more information." );

pod2usage( -verbose => 1 ) if $opt_help;
pod2usage( -verbose => 2 ) if $opt_man;

pod2usage( -verbose => 1 ) unless $csv_file;

$csv_file  = path($csv_file);

INFO("CSV file: '$csv_file'");

LOGCROAK("CSV file '$csv_file' doesn't exist")
    unless $csv_file->is_file;

my $csv = Text::CSV_XS->new ({ binary => 1 }) or
    LOGDIE("Cannot use CSV: " . Text::CSV->error_diag ());
$csv->sep_char(";");
TRACE("CSV-Datei: " . $csv_file);
open my $fh, "<:encoding(utf8)", $csv_file->stringify
    or LOGDIE("$csv_file: $!");
my @rows;
while (my $row = $csv->getline ($fh)) {
    push @rows, $row;
}
$csv->eof or $csv->error_diag;
close $fh or LOGDIE("$csv_file: $!");

#foreach my $row (@rows) {
#    say join "|", @$row;
#}

my $schema = UBR::Geo::Helper::get_schema();

my @header = @{shift @rows}; 
foreach my $row (@rows) {
    my $map = $schema->resultset('Map')->search({
            filename => $row->[0],
    })->first;        
    unless ($map) {
        say $row->[0] . " not found";
        next;
    }
    my ($count) = $row->[0] =~ /[^_]+_(\d{4})/;
    my ($year)  = $row->[6] =~ /([\d\/]+)/;
    $row->[4] =~ s/\s*=.*$//;
    my $column = {
        filename    => $row->[0],
        call_number => $row->[1],
        bvnr        => $row->[2],
        mab331      => $row->[4],
        u_mab089    => $count,
        u_mab331    => $row->[5],
        mab425a     => $row->[6],
        year        => $year,
    };        
    #say Dumper($column);
    $map->update($column);
    #$map->insert($column);
}

=encoding utf-8

=head1 NAME
 
bibliography_from_csv.pl - read bibliographic meta data from CSV and insert it in database  

=head1 SYNOPSIS

bibliography_from_csv.pl [options]  

 Options:
   --help         display this help and exit
   --man          display extensive help

   --csv          CSV file with bibliographic meta data

 Examples:
   bibliography_from_csv.pl --csv ubr05510  
   bibliography_from_csv.pl --help
   bibliography_from_csv.pl --man 
   

=head1 DESCRIPTION

Read bibliographic meta data from CSV and insert it in database  

=head1 AUTHOR

Albert Schröder <albert.schroeder@ur.de>

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
