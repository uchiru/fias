# GeoLinker

It helps your to add FIAS to any project

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'geo_linker', git: 'git@github.com:uchiru/geo_linker.git'
```

And then execute:

    $ bundle


## Scripts
```ruby
rails generate geo_linker:install_fias
rake db:migrate
rake geo_linker:parser:import
rake geo_linker:parser:update
```
## Usage

TODO: Write usage instructions here

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

