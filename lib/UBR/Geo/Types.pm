use utf8;
package UBR::Geo::Types;

#ABSTRACT: UBR-Geo Types library

use Type::Library
    -base,
    -declare => qw(
            DBICSchema GeoGDALGeoTransform GeoOGRDataSource GeoOGRDriver 
            GeoGDALGCP GeoOGRLayer
        );

use Type::Utils -all;

BEGIN { extends  qw(
    Types::Standard
    Types::Common::Numeric 
    Types::Common::String
    Types::Path::Tiny
) };

class_type GeoOGRDataSource,    {class => 'Geo::OGR::DataSource'   };
class_type GeoOGRDriver,        {class => 'Geo::OGR::Driver'       };
class_type GeoOGRLayer,         {class => 'Geo::OGR::Layer'        };
class_type GeoGDALGCP,          {class => 'Geo::GDAL::GCP'         };
#class_type GeoGDALGeoTransform, {class => 'Geo::GDAL::GeoTransform'};
class_type DBICSchema,          {class => 'DBIx::Class::Schema'    };


declare GeoGDALGeoTransform, as ArrayRef[Num];

1;

