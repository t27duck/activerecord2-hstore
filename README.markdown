activerecord2-hstore
====================

What is this?
-------------
This is a gem that provides some very basic functionality for working with 
Postgresql's Hstore columns in ActiveRecord 2.

Documentation about the Postgresql Hstore feature can be found 
[here](http://www.postgresql.org/docs/9.1/static/hstore.html)

Requirements (aka boring stuff)
-------------------------------
This gem requires:
* ActiveRecord and ActiveSupport 2.3.x
* pg 
* rspec (for running tests)
* Ruby (Tested on 1.8.7 MRI and REE)
* Postgresql (Tested on 9.1)

Setup (aka more boring stuff)
-----------------------------
Install the gem like you would normally install any gem.

Enable the hstore extension on the postgres database(s) you wish to use.
Ether by creating a migration in your project that runs this SQL statement
or manually running it directly in psql console...
    CREATE EXTENSION IF NOT EXISTS hstore;
Instead of me trying to hack ActiveRecord to add an actual hstore column type,
and risk breaking the universe, just manually write a migration that adds a 
hstore column to your table. Here, I'll even give you an example:
    ALTER TABLE my_table ADD COLUMN some_field hstore;
I recommend you add an index to that column. Supported indexest BTREE, HASH, 
GIST, and GIN. I'll leave you to handle that on your own.

Usage (aka the stuff you care about)
------------------------------------
Now that the boring stuff is out of the way, you need to tell your model that
you have a hstore column.

Assume you have the following table:
    peeps
    id: integer
    name: string
    infos: hstore

You can tell your model infos is a hstore column thusly...

    class Peep < ActiveRecord::Base
      hstore_column :infos
    end

What does that one line get you?
* A getter that returns the hstore column as a hash...
        @peep.infos
        >> {"age" => "25", "haircolor" => "black", "height" => "5'3\"", "likes" => "Cuddling while watching TV"}
* A setter that takes a hash and converts it to a hstore string (or the method can just take a hstore string)
        @peeps.infos = some_hash
* These name scopes:
  * infos\_has\_key (takes a string)
  * infos\_has\_all\_keys (takes a string or an array of strings)
  * infos\_has\_any\_keys (takes a string or an array of strings) 

So what about querying the data in that colum? Well, you can always use the 
standard condisions key in ActiveRecord's find method and use the proper 
syntax from the Postgresql documentation. But if you're like me and like 
using searchlogic, that's not an option. So in the same line in your model,
you can specifiy some keys you'll [TO BE CONTINUED]

Background / Why make this? / Me Rambling
-----------------------------------------
At my current employor, I'm helping to support a rather large Rails 2.3 app 
(that unfortunatly will be stuck in 2.3 for quite some time) that runs on 
Postgresql. The app's primary purpose is reporting on data from its data 
warehouse of well... data. Because it's on Postgresql, the development team
was interested in using some of Postgresql's special features such as array
columns and hstore datatypes. We need the ability to easily take a hash 
and store that as a hstore and read the column out as a hash. Also because
we're big on reporting and use searchlogic for filtering out data, we need
some way to search a hstore field for key with certain values.

To accomplish the first goal, I first needed a way to convert a Postgresql
hstore string into a Ruby hash and back to a string. I'm using the hash and
string methods from [softa's gem](https://github.com/softa/activerecord-postgres-hstore)
that provides hstore support for ActiveRecord 3. With those methods, I created
a way for you to tell ActiveRecord what columns are hstore columns and this 
gem will override the default column getter method to return a hash and the
setter method to accept a hash which it then converts into a hstore string.

Part two of this gem is determining a way to query a hstore field. I decided
to have the gem generate searchlogic-like named scopes by sepcifying in the
model what keys in the hstore column you'll want to filter on. The gem will 
create scopes in the style of "mycolumn\_key\_eq", "mycolumn\_key\_like", etc.
