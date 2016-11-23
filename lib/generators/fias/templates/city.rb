class Fias::City < ActiveRecord::Base
  self.table_name = "fias_cities"
  self.primary_key = "guid"

  belongs_to :region, foreign_key: 'region_code', primary_key: 'region_code'

  def pretty_name
    "#{short_name} #{formal_name}"
  end
end
