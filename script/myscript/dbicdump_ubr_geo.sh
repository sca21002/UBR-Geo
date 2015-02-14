dbicdump -I lib -o dump_directory=./lib \
    -o use_moose=1 -o overwrite_modifications=1 -o preserve_case=1 \
    -o debug=1 \
    UBR::Geo::Schema \
    dbi:Pg:dbname=ubrgeo ubrgeo
