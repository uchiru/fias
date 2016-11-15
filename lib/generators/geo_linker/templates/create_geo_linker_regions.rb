class CreateGeoLinkerRegions < ActiveRecord::Migration
  def change
    create_table :geo_linker_regions, id: false do |f|
      f.string :id
      f.string :guid, primary: true
      f.string :short_name
      f.string :formal_name
      f.string :region_code
      f.string :official_name
      f.string :is_city
      f.boolean :level
      f.string :live_status

      f.timestamps
    end
  end
end
