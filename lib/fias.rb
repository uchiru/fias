require "fias/version"
require "fias/gem_path"
require "fias/parser"
require "fias/city"
require "fias/region"
require "fias/railtie" if defined?(Rails)

I18n.load_path += Dir.glob( Fias::GEM_PATH + "/lib/config/locales/*.{rb,yml}" )
