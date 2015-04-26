dbicdump -I lib -o dump_directory=./lib \
    -o use_moose=1 -o overwrite_modifications=1 -o preserve_case=1 \
    -o db_schema='["ubr_geo"]'\
    -o moniker_map='{ gcps => "GCP"}' \
    -o debug=1 \
    UBR::Geo::Schema \
    dbi:Pg:dbname=ubr_geo ubr_geo
