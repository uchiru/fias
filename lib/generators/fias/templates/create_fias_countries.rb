class CreateFiasCountries < ActiveRecord::Migration
  def change
    create_table :fias_countries, id: false do |f|
      f.string :iso
      f.string :name
      f.string :full_name
      f.string :location
      f.string :alpha2
      f.string :alpha3

      f.timestamps
    end
  end
end
