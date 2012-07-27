module Hstore
  module ActiveRecord
    # Called when included in ActiveRecord. Extends the Extensions module.
    def self.included(base)
      base.extend Extensions
    end
    
    module Extensions
      # Creates a series of methods and named scopes for a hstore column. This is the primary
      # method you should use to invoke this gem in a model.
      #
      # USAGE IN A MODEL:
      # class Foo < ActiveRecord::Base
      #   hstore_column :some_column, [:array_of_possible_keys, :you_may_want, :to_query_on]
      # end
      def hstore_column(column, keys=[])
        create_getter_and_setter(column)
        create_hstore_key_availability_scopes(column)
        Array(keys).each{ |key| create_hstore_key_search_scopes(column, key) }
      end

      # Creates and overrides ActiveRecord's getter and setter methods for the hstore column.
      # The getter returns a hash. The setter accepts and converts either a hash or a valid
      # hstore string.
      def create_getter_and_setter(column)
        define_method column.to_sym do
          read_attribute(column.to_sym).to_s.from_hstore
        end

        define_method "#{column}=".to_sym do |value|
          value = {} if value.nil?
          value ||= value.is_a?(String) ? value : value.to_hstore
          write_attribute(column.to_sym, value)
        end
      end

      # Creates named scopes for the hstore column allowing you to determine if the column
      # contains a given key or set of keys.
      def create_hstore_key_availability_scopes(column)
        named_scope "#{column}_has_key".to_sym, Proc.new{ |key|
          { :conditions => ["#{column} ? :key", {:key => key}] }
        }
        named_scope "#{column}_has_all_keys".to_sym, Proc.new{ |keys|
          { :conditions => ["#{column} ?& ARRAY[:keys]", {:keys => Array(keys)}] }
        }
        named_scope "#{column}_has_any_key".to_sym, Proc.new{ |keys|
          { :conditions => ["#{column} ?| ARRAY[:keys]", {:keys => Array(keys)}] }
        }
      end

      # Creates a slew of searchlogic-like named scopes to query for a key on a hstore column
      def create_hstore_key_search_scopes(column, key)
        named_scope "#{column}_#{key}_eq".to_sym, Proc.new{ |value|
          { :conditions => ["#{column} -> '#{key}' = ?", value.to_s] }
        }
        named_scope "#{column}_#{key}_neq".to_sym, Proc.new{ |value|
          { :conditions => ["#{column} -> '#{key}' != ?", value.to_s] }
        }
        named_scope "#{column}_#{key}_eq_any".to_sym, Proc.new{ |value|
          { :conditions => ["#{column} -> '#{key}' IN(?)", value.map{|v| v.to_s} ] }
        }
        named_scope "#{column}_#{key}_neq_any".to_sym, Proc.new{ |value|
          { :conditions => ["#{column} -> '#{key}' NOT IN(?)", value.map{|v| v.to_s} ] }
        }
        named_scope "#{column}_#{key}_like".to_sym, Proc.new{ |value|
          { :conditions => ["#{column} -> '#{key}' ILIKE(?)", "%#{value.to_s}%"] }
        }
        named_scope "#{column}_#{key}_begins_with".to_sym, Proc.new{ |value|
          { :conditions => ["#{column} -> '#{key}' ILIKE(?)", "#{value.to_s}%"] }
        }
        named_scope "#{column}_#{key}_ends_with".to_sym, Proc.new{ |value|
          { :conditions => ["#{column} -> '#{key}' ILIKE(?)", "%#{value.to_s}"] }
        }
      end
    end
  end
end


