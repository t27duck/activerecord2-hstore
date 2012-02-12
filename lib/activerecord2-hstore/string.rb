class String
  # Generates a hash from an hstore string format.
  #
  # Original implementation from:
  # https://github.com/softa/activerecord-postgres-hstore/blob/master/lib/activerecord-postgres-hstore/string.rb
  def from_hstore
    quoted_string = /"[^"\\]*(?:\\.[^"\\]*)*"/
    unquoted_string = /[^\s=,][^\s=,\\]*(?:\\.[^\s=,\\]*|=[^,>])*/
    string = /(#{quoted_string}|#{unquoted_string})/
    hstore_pair = /#{string}\s*=>\s*#{string}/

    token_pairs = (scan(hstore_pair)).map { |key, value| [key, value =~ /^NULL$/i ? nil : value] }
    token_pairs = token_pairs.map { |key, value|
      [key, value].map { |element| 
        case element
        when nil then element
        when /^"(.*)"$/ then $1.gsub(/\\(.)/, '\1')
        else element.gsub(/\\(.)/, '\1')
        end
      }
    }
    Hash[ token_pairs ]
  end
end
