use utf8;
package UBR::Geo::OGR::Layer;

# ABSTRACT: OGR layer

use Geo::OGR;
use Moose;
use MooseX::AttributeShortcuts;
use UBR::Geo::Types qw(GeoOGRLayer);

has 'layer' => (
    is => 'ro',
    isa => GeoOGRLayer,
    required => 1,
    handles => [qw(
        CreateFeature GetNextFeature InsertFeature Schema SetAttributeFilter
        SetFeature
    )],
); 

around BUILDARGS => sub {
    my $orig = shift;
    my $class = shift;
 
    if ( @_ == 1 && ref $_[0] eq 'Geo::OGR::Layer' ) {
        return $class->$orig(layer => $_[0]);
    }
    else {
        return $class->$orig(@_);
    }
};

sub get_feature {
    my ($self, $cond) = @_;

    die "Filter condition must be a hashref" 
        unless ref $cond eq 'HASH';
    my ($key, $val) =  each %$cond;
    $self->SetAttributeFilter("$key = '$val'");
    my $feature = $self->GetNextFeature();
    if ($feature) {
        my $fid = $feature->GetFID(); 
        return $fid; 
    } 
    return;
}


__PACKAGE__->meta->make_immutable();

1;
