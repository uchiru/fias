class Fias::City < ActiveRecord::Base
  self.table_name = "fias_cities"
  self.primary_key = "guid"

  def pretty_name
    "#{short_name} #{formal_name}"
  end
end
