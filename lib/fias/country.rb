class Fias::Country < ActiveRecord::Base
  self.table_name = 'fias_countries'
  self.primary_key = 'iso'
  # :iso, :name, :full_name, :name, :location, :alpha2, :alpha3, :regions_list, :time_zones, :region_time_zones

  has_many :regions

  def self.data
    data_path = File.join( File.dirname(__FILE__), 'data/countries.json' )
    @data ||= JSON.parse(IO.read(data_path))
  end

  def self.import
    progress = ProgressBar.new("Countries", data.count)
    data.each_with_index.map do |(_id, options), index|
      ActiveRecord::Base.transaction do
        country = self.create!(
          iso: options['iso'],
          name: options['name'],
          full_name: options['full_name'],
          name: options['name'],
          location: options['location'],
          alpha2: options['alpha2'],
          alpha3: options['alpha3'],
          regions_list: options['regions'],
          time_zones: options['time_zones'],
          region_time_zones: options['region_timezones']
        )
        Fias::Region.where(region_code: country.regions_list.map(&:first)).update_all(country_id: country.id)
      end
      progress.set(index + 1)
    end
    progress.finish
  end
end
