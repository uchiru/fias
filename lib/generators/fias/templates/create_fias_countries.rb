class CreateFiasCountries < ActiveRecord::Migration
  def change
    create_table :fias_countries, id: false do |t|
      t.string :iso, primary: true
      t.string :name
      t.string :full_name
      t.string :location
      t.string :alpha2
      t.string :alpha3
      t.json :regions_list
      t.json :time_zones
      t.json :region_time_zones

      t.timestamps
    end
  end
end
