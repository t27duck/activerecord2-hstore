class Hash
  # Generates an hstore string format. This is the format used to insert or update stuff in the database.
  #
  # Original implementation from:
  # https://github.com/softa/activerecord-postgres-hstore/blob/master/lib/activerecord-postgres-hstore/hash.rb
  def to_hstore
    return "" if empty?

    map { |key, value| 
      pair = [key, value].map { |element| 
        item = element.to_s.gsub(/"/, '\"').gsub(/'/, "\'")
        if element.nil?
          'NULL'
        elsif item =~ /[,\s=>]/ || item.blank?
          '"%s"' % item
        else
          item
        end
      }

      "%s=>%s" % pair
    } * ","
  end
end
