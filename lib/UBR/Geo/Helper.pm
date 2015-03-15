package UBR::Geo::Helper;

# ABSTRACT: Helper functions for UBR::Geo

use Carp;
use Config::ZOMG;
use DBIx::Class::Helpers::Util qw(normalize_connect_info);
use Path::Tiny;
use UBR::Geo::Schema;

sub get_connect_info {

    my $config_dir = path(__FILE__)->parent(4); 
    my $config_hash = Config::ZOMG->open(
        name => 'ubr_geo',
        path => $config_dir,
    ) or confess "No config file in '$config_dir'";
    
    my $connect_info = $config_hash->{'Model::UBR::GeoDB'}{connect_info};
    $connect_info = normalize_connect_info(@$connect_info)
        if (ref $connect_info eq 'ARRAY' );    
    confess "No database connect info" unless  $connect_info;
    return $connect_info;
}


sub get_schema {

    my $connect_info = get_connect_info();
    my $schema = UBR::Geo::Schema->connect($connect_info);
    $schema->storage->ensure_connected;
    return $schema;
}

1;
