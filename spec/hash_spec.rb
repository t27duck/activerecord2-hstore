require "spec_helper"

describe Hash do
  describe "Converting a hash to a hstore string" do
    it "#to_hstore" do
      {:a=>"b"}.to_hstore.should == "a=>b"
      {"a"=>"b"}.to_hstore.should == "a=>b"
      {:a=>:b}.to_hstore.should == "a=>b"
      {"a"=>"2"}.to_hstore.should == "a=>2"
      {:a=>2}.to_hstore.should == "a=>2"
      {2=>2}.to_hstore.should == "2=>2"
      {"a b"=>"b"}.to_hstore.should == "\"a b\"=>b"
      {"a b"=>"b c"}.to_hstore.should == "\"a b\"=>\"b c\""
      {"a"=>"b c"}.to_hstore.should == "a=>\"b c\""
      {"a"=>"'c"}.to_hstore.should == "a=>'c"
      {"a'f"=>"b'c"}.to_hstore.should == "a'f=>b'c"
      {"a"=>"b' c"}.to_hstore.should == "a=>\"b' c\""
      {"a"=>"b 'c"}.to_hstore.should == "a=>\"b 'c\""
      {"a"=>"b'"}.to_hstore.should == "a=>b'"
      {"a"=>"'b"}.to_hstore.should == "a=>'b"
    end
    
    it "converts a multiball hash to a hstore string" do
      all_should_match({"a"=>"b", "c"=>"d"}, [/a=>b/, /c=>d/])
      all_should_match({:a=>"b", "c"=>:d}, [/a=>b/, /c=>d/])
      all_should_match({"a 1"=>"b 1", "c"=>"d"}, [/\"a 1\"=>\"b 1\"/, /c=>d/])
      all_should_match({"a"=>"b", "c"=>"d 1"}, [/a=>b/, /c=>\"d 1\"/])
      all_should_match({"a"=>"b", "c 1"=>"d"}, [/a=>b/, /\"c 1\"=>d/])
      all_should_match({:a=>:b, "c 1"=>:"d 1"}, [/a=>b/, /\"c 1\"=>\"d 1\"/])
      all_should_match({"a"=>"b", :c=>:d, "e 1"=>"f 1"}, [/a=>b/, /c=>d/, /\"e 1\"=>\"f 1\"/])
      all_should_match({"a 1"=>"b'1", "c"=>"d"}, [/\"a 1\"=>b'1/, /c=>d/])
      all_should_match({"a 1"=>"b' 1", "c"=>"d"}, [/\"a 1\"=>\"b' 1\"/, /c=>d/])
    end

    def all_should_match(hash, expects)
      expects.each do |e|
        hash.to_hstore.should match(e)
      end
    end
  end
end
