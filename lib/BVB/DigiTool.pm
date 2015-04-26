use utf8;
package BVB::DigiTool;

# ABSTRACT: Class for fetching the DigiTool persistent identifier pid

use Moose;
use BVB::Types qw(LWPUserAgent);
use LWP::UserAgent;
use MooseX::AttributeShortcuts;
use URI::FromHash qw(uri_object);
use namespace::autoclean;

has 'user_agent' => ( is => 'lazy', isa => LWPUserAgent );

sub get_uri {
    my ($self, $prodnr) = @_; 


    my $query = { prodnr => $prodnr };  

    my $uri_hash = { 
        scheme => 'http',
        host   => 'digipool.bib-bvb.de',
        # port   => 80,
        path   => '/bvb/anwender/getProduktionsnummerKarten.pl',
        query  => $query,
    };  

    return uri_object($uri_hash);
}

sub _build_user_agent { LWP::UserAgent->new() }


sub get_pid {
    my ($self, $prodnr) = @_;

    my $response = $self->user_agent->get( $self->get_uri($prodnr) );

    if ($response->is_success) {    # uncoverable branch false
        my $content = $response->decoded_content;
        my ($pid) = $content =~ m#<pid>\s*(\d+)\s*</pid>#;
        return $pid;
    }
    else {
        # uncoverable statement
        die 'Fetching ' . $prodnr . ' failed: ' .  $response->status_line;
    }
}


__PACKAGE__->meta->make_immutable;
1;

