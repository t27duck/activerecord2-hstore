require "activerecord2-hstore/version"
require "activerecord2-hstore/string"
require "activerecord2-hstore/hash"
require "activerecord2-hstore/hstore"

module Activerecord2
  module Hstore
    # Your code goes here...
  end
end

ActiveRecord::Base.send(:include, Hstore::ActiveRecord)
