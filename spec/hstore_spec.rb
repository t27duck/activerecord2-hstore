require "spec_helper"

ActiveRecord::Base.establish_connection(
  :adapter => "postgresql",
  :database => "activerecord2_hstore_test",
  :encoding => "unicode"
)

ActiveRecord::Base.connection.execute("DROP TABLE IF EXISTS my_hstores")
ActiveRecord::Base.connection.create_table(:my_hstores) do |t|
  t.string :label
end
ActiveRecord::Base.connection.execute("CREATE EXTENSION IF NOT EXISTS hstore")
ActiveRecord::Base.connection.execute("ALTER TABLE my_hstores ADD COLUMN some_field hstore")

class MyHstore < ActiveRecord::Base
  hstore_column :some_field, [:key]
end

describe Hstore do
  before(:each) do
    ActiveRecord::Base.connection.increment_open_transactions
    ActiveRecord::Base.connection.begin_db_transaction
  end

  after(:each) do
    ActiveRecord::Base.connection.rollback_db_transaction
    ActiveRecord::Base.connection.decrement_open_transactions
  end

  it "creates the correct named scopes" do
    %w(eq neq eq_any neq_any like begins_with ends_with).each do |predicate|
      MyHstore.should respond_to("some_field_key_#{predicate}")
    end
  end

  describe "available methods" do
    let(:subject) do
      MyHstore.new
    end
  
    it "creates a getter and setter for the some_field" do
      subject.should respond_to(:some_field)
      subject.should respond_to(:some_field=)
    end

    it "uses ActiveRecord's read_attribute for the getter method" do
      subject.should_receive(:read_attribute).with(:some_field).and_return("a=>b")
      subject.some_field
    end

    describe "setter method" do
      it "uses ActiveRecord's write_attribute" do
        subject.should_receive(:write_attribute)
        subject.some_field = {:a => :b}
      end

      it "handles nil input" do
        subject.should_receive(:write_attribute)
        subject.some_field = nil
      end

      it "can also accept a hstore string instead of a hash" do
        subject.stub(:write_attribute)
        subject.some_field = "a=>b"
      end
    end
  end

  describe "querying data" do
    before(:each) do
      MyHstore.create( :label=> "A", :some_field => {"key" => "1"}.to_hstore )
      MyHstore.create( :label=> "B", :some_field => {:key => 1, "a" => "b"}.to_hstore )
      MyHstore.create( :label=> "C", :some_field => {"key" => "2"}.to_hstore )
      MyHstore.create( :label=> "D", :some_field => {"key" => "3"}.to_hstore )
      MyHstore.create( :label=> "E", :some_field => {"key" => "123456789"}.to_hstore )
      MyHstore.create( :label=> "F", :some_field => {"c" => "x"}.to_hstore )
    end

    it "queries for the records containing a specific key" do
      result = MyHstore.some_field_has_key("a")
      result.map(&:label).should include "B"
      %w(A C D E F).each do |key|
        result.map(&:label).should_not include key
      end
    end

    it "queries for the records containing a set keys" do
      result = MyHstore.some_field_has_all_keys(["a", "key"])
      result.map(&:label).should include "B"
      %w(A C D E F).each do |key|
        result.map(&:label).should_not include key
      end
      
      result = MyHstore.some_field_has_all_keys("a")
      result.map(&:label).should include "B"
      %w(A C D E F).each do |key|
        result.map(&:label).should_not include key
      end
    end

    it "queries for the records containing any set keys" do
      result = MyHstore.some_field_has_any_key(["a", "c"])
      %w(B F).each do |key|
        result.map(&:label).should include key
      end
      %w(A C D E).each do |key|
        result.map(&:label).should_not include key
      end
      
      result = MyHstore.some_field_has_any_key("a")
      result.map(&:label).should include "B"
      %w(A C D E F).each do |key|
        result.map(&:label).should_not include key
      end
    end

    it "queries the right data for the named scope *_eq" do
      result = MyHstore.some_field_key_eq("1")
      %w(A B).each do |key|
        result.map(&:label).should include key
      end
      %w(C D E F).each do |key|
        result.map(&:label).should_not include key
      end
    end

    it "queries the right data for the named scope *_neq" do
      result = MyHstore.some_field_key_neq("1")
      %w(A B F).each do |key|
        result.map(&:label).should_not include key
      end
      %w(C D E).each do |key|
        result.map(&:label).should include key
      end
    end

    it "queries the right data for the named scope *_eq_any" do
      result = MyHstore.some_field_key_eq_any(["2", "3"])
      %w(A B E F).each do |key|
        result.map(&:label).should_not include key
      end
      %w(C D).each do |key|
        result.map(&:label).should include key
      end
    end

    it "queries the right data for the named scope *_neq_any" do
      result = MyHstore.some_field_key_neq_any(["2", "3"])
      %w(A B E).each do |key|
        result.map(&:label).should include key
      end
      %w(C D F).each do |key|
        result.map(&:label).should_not include key
      end
    end

    it "queries the right data for the named scope *_like" do
      result = MyHstore.some_field_key_like("456")
      result.map(&:label).should include "E"
      %w(A B C D F).each do |key|
        result.map(&:label).should_not include key
      end
    end
    
    it "queries the right data for the named scope *_begins_with" do
      result = MyHstore.some_field_key_begins_with("123")
      result.map(&:label).should include "E"
      %w(A B C D F).each do |key|
        result.map(&:label).should_not include key
      end
    end
    
    it "queries the right data for the named scope *_ends_with" do
      result = MyHstore.some_field_key_ends_with("789")
      result.map(&:label).should include "E"
      %w(A B C D F).each do |key|
        result.map(&:label).should_not include key
      end
    end

  end

end
