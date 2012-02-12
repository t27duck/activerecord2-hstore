# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "activerecord2-hstore/version"

Gem::Specification.new do |s|
  s.name        = "activerecord2-hstore"
  s.version     = Activerecord2::Hstore::VERSION
  s.authors     = ["Tony Drake"]
  s.email       = ["t27duck@gmail.com"]
  # s.homepage    = ""
  s.summary     = %q{Some basic support to help integrate Postgresql's HStore into a Rails 2.3 app}
  s.description = %q{TODO: Write a gem description}

  s.rubyforge_project = "activerecord2-hstore"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_development_dependency "rspec", ">=2.0.0"
  s.add_dependency "pg"
  
  # s.add_runtime_dependency "rest-client"
end
