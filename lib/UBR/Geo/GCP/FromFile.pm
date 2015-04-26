use utf8;
package UBR::Geo::GCP::FromFile;

# ABSTRACT: Class for reading GCPs from a file

use Moose;
   
use MooseX::AttributeShortcuts;
use UBR::Geo::Types qw(ArrayRef File Str);
use Carp;

has 'srid' => (
    is => 'ro',
    required => 1,
    isa => Str,
);

with 'UBR::Geo::GCP';   # role requires srid, mind the order

has 'file' => (
    is => 'ro',
    isa => File,
    handles => [qw(basename)],
    coerce => 1,
    required => 1,
);

has 'filestem' => (
    is => 'lazy',
    isa => Str,
);

has 'header' => (
    is => 'lazy',
    isa => ArrayRef[Str], 
);



# GCPs saved with QGIS georeferencing plugin have negative pixel_y values;
# GCPs define origin of pixel coordinates in the left upper corner
# therefore the values of pixel_y are positive

sub _build_gcps {
    my $self = shift;

    my $data = $self->file->slurp;
   
    my @lines  = split "\n", $data;
    my @header = split ',', shift @lines;
    
    die('Unexpected header ' . join('|', @header . " <> " . join('|', @{$self->header})) ) 
	unless join('|', @header) eq join('|', @{$self->header});
    
    my (%row, @coords);
    foreach my $line ( @lines ) {
        next if $line =~ /^\s*$/;
        if ( exists $row{enable} && $row{enable} eq 0 ) {
            carp "line '$line' left out as GCP";
        }
        @row{@header} = map { s/^\s+|\s+$//gr }  split ',', $line;
        $row{pixelX} =   sprintf "%.0f", $row{pixelX};
        $row{pixelY} = - sprintf "%.0f", $row{pixelY};  # mind the minus op
        push @coords, { %row };
    }
   
    my @gcps = map {
        Geo::GDAL::GCP->new( @{$_}{ qw(mapX mapY mapZ pixelX pixelY) } )
    }  @coords;
    return \@gcps;    
}

sub _build_filestem {
    my $self = shift;
    
    my ($filestem) = $self->basename =~ qr/^([^.]*)\./;
    return $filestem;
}


sub _build_header { [ qw(mapX mapY pixelX pixelY enable) ] }


__PACKAGE__->meta->make_immutable();

1; # Magic true value required at end of module
 
__END__

