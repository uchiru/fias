class CreateFiasCities < ActiveRecord::Migration
  def change
    create_table :fias_cities, id: false do |f|
      f.string :id
      f.string :guid, primary: true
      f.string :short_name
      f.string :formal_name
      f.string :region_code
      f.string :official_name
      f.string :level
      f.string :live_status

      f.timestamps
    end
  end
end
