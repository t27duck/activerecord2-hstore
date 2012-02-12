activerecord2-hstore
====================

What is this?
-------------
This is a gem that provides some very basic functionality for working with 
Postgresql's Hstore columns in ActiveRecord 2.

Background/Why make this?
--------------
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
to have the gem generate searchlogic-like named scopes.
