module ActiveRecord
  module ConnectionAdapters
    class PostgreSQLAdapter < AbstractAdapter
      def quote_with_hstore(value, column=nil)
        # We must escape quotes here
        return "hstore('#{value.gsub("'", "''")}')" if column && column.sql_type == "hstore"
        quote_without_hstore(value, column)
      end

      alias_method_chain :quote, :hstore
    end
  end
end
