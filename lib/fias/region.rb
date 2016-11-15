class Fias::Region < ActiveRecord::Base
  self.table_name = "fias_regions"
  self.primary_key = "guid"
end
