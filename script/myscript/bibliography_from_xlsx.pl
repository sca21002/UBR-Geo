#!/usr/bin/env perl
use utf8;
use Path::Tiny;
use FindBin qw($Bin);
use lib path($Bin)->parent(2)->child('lib')->stringify;
use Spreadsheet::ParseXLSX;
use Log::Log4perl qw(:easy);
use Modern::Perl;
use UBR::Geo::Helper;
use English qw( -no_match_vars );   # Avoids regex performance penalty
use Pod::Usage;
use Getopt::Long;
use Data::Dumper;

binmode(STDOUT, ":utf8");

my $fingerprint = 'Verwaltungs-Excel für das Projekt GeoPortOst';

my $logfile = path($Bin)->parent(2)->child('bibliography_from_xlsx.log');

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

my ($xlsx_file, $opt_help, $opt_man);

GetOptions (
    "xlsx=s"    => \$xlsx_file,
    'help!'    => \$opt_help,
    'man!'     => \$opt_man,
) or pod2usage( "Try '$PROGRAM_NAME --help' for more information." );

pod2usage( -verbose => 1 ) if $opt_help;
pod2usage( -verbose => 2 ) if $opt_man;

pod2usage( -verbose => 1 ) unless $xlsx_file;

$xlsx_file  = path($xlsx_file);

INFO("Excel file: '$xlsx_file'");

LOGCROAK("Excel file '$xlsx_file' doesn't exist")
    unless $xlsx_file->is_file;

my $parser = Spreadsheet::ParseXLSX->new;
my $workbook = $parser->parse($xlsx_file->stringify );

my $worksheet1 = $workbook->worksheet('Tabelle1');

LOGCROAK("'$xlsx_file' is no correct Excel file of GeoPortOst")
    unless $worksheet1->get_cell(0,1)->value();

INFO('Excel file of GeoPortOst accepted');

my $schema = UBR::Geo::Helper::get_schema();

my ( $row_min, $row_max ) = $worksheet1->row_range();
for my $row ( 7 .. $row_max ) {                
    my $cell = $worksheet1->get_cell( $row, 12 );
    if ($cell && $cell->value) {
        my $val = $cell->value; 
        my ($filename) = $val =~ 
    m#http://www\.nbn-resolving\.de/urn:nbn:de:bvb:355-(ubr\d{5}-\d{3,5})-\d#;
        $filename =~ s/-/_/;
        INFO("Working on '$filename'");
        
        my $map = $schema->resultset('Map')->search({
                filename => $filename,
        })->first;        
        unless ($map) {
            # INFO("No Map for '$filename'");
            next;
        }
        my $call_number = $worksheet1->get_cell( $row, 9 )->value;
        say "Call-number: '$call_number'";
        my $mab331 = $worksheet1->get_cell( $row, 3 )->value;
        say "Mab331: '$mab331'";
        my $author = $worksheet1->get_cell( $row, 4 )->value;
        my $title  = $worksheet1->get_cell( $row, 6 )->value;
        my $mab590a = $author . ': ' if $author;
        $mab590a .= $title;
        say "Mab590a: '$mab590a'";
        my $mab425a = $worksheet1->get_cell( $row, 7 )->value;  
        say "Mab425a: '$mab425a'";     
        my ($year) = $mab425a =~ /(\d{4})/;
        say "Year: $year"; 
        my $cell = $worksheet1->get_cell( $row,10);
        warn "No cell" unless $cell;
        my $bvnr;
        if ($cell) {
            $bvnr = $cell->value;
            say "BV-Nr.: $bvnr";
        }
        my $column = {
            call_number => $call_number,
            mab331      => $mab331,
            mab590a     => $mab590a,
            mab425a     => $mab425a,
            year        => $year,
        };
        $column->{bvnr} = $bvnr if $bvnr;
        # say Dumper($column);
        $map->update($column);
    }
}

=encoding utf-8

=head1 NAME
 
bibliography_from_xlsx.pl - read bibliographic meta data from Excel file

=head1 SYNOPSIS

bibliography_from_xlsx.pl [options]  

 Options:
   --help         display this help and exit
   --man          display extensive help

   --xlsx         Excel file with bibliographic meta data

 Examples:
   bibliography_from_xlsx.pl --xlsx ubr05510  
   bibliography_from_xlsx.pl --help
   bibliography_from_xlsx.pl --man 
   

=head1 DESCRIPTION

Read bibliographic meta data from Excel file and insert it into the database  

=head1 AUTHOR

Albert Schröder <albert.schroeder@ur.de>

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
