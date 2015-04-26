use utf8;
use strict;
use warnings;
use FindBin qw($Bin);
use Path::Tiny;
use lib path($Bin)->parent->child('lib')->stringify;
use Test::More;

BEGIN {
    use_ok( 'BVB::DigiTool' ) or exit;
}

ok ( my $digitool = BVB::DigiTool->new(), 'new instance');
like (
    my $uri = $digitool->get_uri('ubr05510_6169'),
    qr/prodnr=ubr05510_6169/,
    'uri'
);

SKIP: {
    my $response = $digitool->user_agent->get($uri);
    skip $response->status_line, 2 unless $response->is_success;
    ok(my $pid = $digitool->get_pid('ubr05510_6169'), 'fetch pid');
    is($pid, 7750824, 'pid ok');
}

done_testing();

