use utf8;
package BVB::Types;

#ABSTRACT: BVB Types library

use Type::Library
    -base,
    -declare => qw(LWPUserAgent);

use Type::Utils -all;

#BEGIN { extends  qw(
#    Types::Standard
#) };

class_type LWPUserAgent, {class => 'LWP::UserAgent'};

1;
