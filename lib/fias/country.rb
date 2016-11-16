class Fias::Country < ActiveRecord::Base
  self.table_name = "fias_countries"

  def self.import
    data_path = File.join( File.dirname(__FILE__), 'data/countries.json' )

    data = JSON.parse(IO.read(data_path))
    progress = ProgressBar.new("Countries", data.count)
    data.each_with_index.map do |(id, options), index|
      self.create(
        id: id,
        name: options['name'],
        full_name: options['full_name'],
        name: options['name'],
        full_name: options['full_name'],
        location: options['location'],
        alpha2: options['alpha2'],
        alpha3: options['alpha3']
      )
      progress.set(index + 1)
    end
    progress.finish
  end
end
