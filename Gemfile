source "http://rubygems.org"

# Specify your gem's dependencies in activerecord2-hstore.gemspec
gemspec

gem "activerecord", "~> 2.3.0", :require => "active_record"
gem "activesupport", "~> 2.3.0", :require => "active_support"

platform :jruby do 
   gem "activerecord-jdbcpostgresql-adapter"
end

platform :ruby do
   gem "pg"
end
