module Hstore
  module ActiveRecord
    # USAGE: When included in an ActiveRecord model, you can create a set of named scopes
    # for a HSTORE Postgresql field-key combination in the table.
    #
    # You can also mark a key as a hstore column to create getting/setter methods that return
    # and take a hash (respectively)
    #
    # class Foo < ActiveRecord::Base
    #   include Hstore::ActiveRecord
    #   hstore_scopes :column_name, :key
    #   hstore_column :column_name
    # end
    #
    # Foo.column_name_key_eq("bar")
    # Foo.column_name_key_in([3,"bar","blah"])
    #
    # f = Foo.new
    # f.column_name = {:a => "bar", "b" => "fizz"}

    def self.included(base)
      base.extend Extensions
    end
    
    module Extensions
      def hstore_column(column)
        define_method column.to_sym do
          read_attribute(column.to_sym).to_s.from_hstore
        end

        define_method "#{column}=".to_sym do |value|
          value = value.is_a?(String) ? value : value.to_hstore
          write_attribute(column.to_sym, value)
        end

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

      def hstore_scopes(column, key)
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


