use utf8;
package UBR::Geo::GCP::FromDB;

# ABSTRACT: Class for reading GCPs from database

use Moose;
   
use MooseX::AttributeShortcuts;
use UBR::Geo::Types qw(DBICSchema NonEmptySimpleStr Str);
use UBR::Geo::Helper;
use DBIx::Class::ResultClass::HashRefInflator;
use Modern::Perl;
# use Carp;
# use Data::Dumper;

has 'srid' => (
    is => 'rw',
    lazy => 1,
    isa => Str,
    builder => 1,
);

with 'UBR::Geo::GCP';   # role requires srid, mind the order

has 'filename' => (
    is => 'ro',
    isa => NonEmptySimpleStr,
    required => 1,
);
    
has 'schema' => (
    is  => 'lazy',
    isa => DBICSchema,
);

sub _build_schema { UBR::Geo::Helper::get_schema() }


sub _build_gcps {
    my $self = shift;


    my @columns = (qw(x y z pixel line info id));
    my @gcps = $self->schema->resultset('GCP')->search(
        {
            'map.filename' => $self->filename,
            
        },
        {
            columns =>  [ @columns, 'srid' ],
            join => 'map',
            result_class => 'DBIx::Class::ResultClass::HashRefInflator',
        }
    )->all;

    $self->srid($gcps[0]->{srid});

    @gcps = map {
        $_->{id} .= '';
        Geo::GDAL::GCP->new( @{$_}{ @columns } )
    }  @gcps;

    return \@gcps;
}

sub _build_srid {
    my $self = shift;


    my $gcp = $self->schema->resultset('GCP')->search(
        {
            'map.filename' => $self->filename,
            
        },
        {
            columns => [ 'srid' ],
            join => 'map',
        }
    )->first;
    
    return $gcp->srid; 
}

__PACKAGE__->meta->make_immutable();

1; # Magic true value required at end of module
 
__END__
