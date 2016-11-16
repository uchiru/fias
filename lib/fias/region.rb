class Fias::Region < ActiveRecord::Base
  self.table_name = "fias_regions"
  self.primary_key = "guid"

  def pretty_name
    case short_name.strip
    when "Чувашия"
      short_name.strip
    when "Респ"
      I18n.t "fias_regions.republic", name: official_name
    when "обл"
      I18n.t "fias_regions.region", name: official_name
    when "АО"
      official_name.in?("Югра") ?
        self.official_name : I18n.t("fias_regions.ao", name: official_name)
    when "Аобл"
      I18n.t "fias_regions.aobl", name: official_name
    when "край"
      I18n.t "fias_regions.edge", name: official_name
    else
      official_name
    end
  end
end
