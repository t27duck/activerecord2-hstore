require "spec_helper"

describe String do
  describe "#from_hstore" do
    it "handles a single key value pair" do
      "a=>b".from_hstore.should == {"a" => "b"}
      "\"a\"=>\"b\"".from_hstore.should == {"a" => "b"}
      "\"a 1\"=>b".from_hstore.should == {"a 1" => "b"}
      "\"a 1\"=>\"b 1\"".from_hstore.should == {"a 1" => "b 1"}
      "1=>b".from_hstore.should == {"1" => "b"}
      "1=>1".from_hstore.should == {"1" => "1"}
    end

    it "converts a multikeyed hstore string to a hash" do
      "a=>b,c=>d".from_hstore.should == {"a" => "b", "c" => "d"}
      "\"a\"=>\"b\",\"c\"=>\"d\"".from_hstore.should == {"a" => "b", "c" => "d"}
      "\"a 1\"=>b,c=>d".from_hstore.should == {"a 1" => "b", "c" => "d"}
      "\"a 1\"=>b,c=>\"d 1\"".from_hstore.should == {"a 1" => "b", "c" => "d 1"}
      "\"a 1\"=>\"b 1\",c=>\"d 1\"".from_hstore.should == {"a 1" => "b 1", "c" => "d 1"}
      "1=>b,c=>\"d 1\"".from_hstore.should == {"1" => "b", "c" => "d 1"}
    end
  end
end
