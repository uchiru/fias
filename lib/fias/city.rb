class Fias::City < ActiveRecord::Base
  self.table_name = "fias_cities"
  self.primary_key = "guid"
end
