class GeoLinker::Region < ActiveRecord::Base
  self.table_name = "geo_linker_regions"
  self.primary_key = "guid"
end
