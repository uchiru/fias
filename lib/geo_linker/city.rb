class GeoLinker::City < ActiveRecord::Base
  self.table_name = "geo_linker_cities"
  self.primary_key = "guid"
end
