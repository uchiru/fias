class CreateFiasRegions < ActiveRecord::Migration
  def change
    create_table :fias_regions, id: false do |f|
      f.string :guid, primary: true
      f.string :aoid
      f.string :short_name
      f.string :formal_name
      f.string :region_code
      f.string :official_name
      f.boolean :is_city
      f.string :level
      f.string :live_status
      f.string :country_id

      f.timestamps
    end
  end
end
