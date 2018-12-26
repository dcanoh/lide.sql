.. _luasql: https://github.com/lidesdk/luasql.sqlite3/blob/package.lide/README.rst

lide.sql
========

SQl Databases support for Lide framework.

===============  ==========  ============== ====================================================================================
  platform          arch        version       build status
===============  ==========  ============== ====================================================================================
  ``Windows``      ``x86``      ``0.2.1``       .. image:: https://ci.appveyor.com/api/projects/status/tgol246fvwsdoq0o/branch/package.lide?svg=true
                                                       :target: https://ci.appveyor.com/project/dcanoh/lide-sql/branch/package.lide
===============  ==========  ============== ====================================================================================


lide.sql library allows us to execute queries in sql databases from lua.


installation
^^^^^^^^^^^^

To install this library I recommend using the command line of lide, using ``lide install``.

*Thus all the dependencies will be installed automatically:*

``$ lide install lide.sql``



dependencies
^^^^^^^^^^^^

The following dependencies are necessary to be able to run the library:

- lide 0.1
- luasql_ 2.1.0
- fbclient 0.5.0



lua API
^^^^^^^

Basic usage functions.

sql.database:new ( string sDatabase, string sqlDriver )
	Create new Database object and connect using given sql driver.

.. code-block:: lua
	
	sqldb = sql.database:new ( 'sqlite3', 'test.db' );

sql.database:exec ( string QueryStatement )
	Executes the given SQL statement.

.. code-block:: lua
	
	sqldb:exec 'select * from sqlite_master'


sql.database:create_table { table_name = { col1name = string col1value, col2name = string col2value } }
	SQLite CREATE TABLE statement is used to create a new table in any of the given database. 
	Creating a basic table involves naming the table and defining its columns and each column's data type.

.. code-block:: lua
	
	sqldb:create_table { lua_packages = {  
	    package_checksum = "CHAR(250)",
	    package_date = "CHAR(250)",
	    package_description = "CHAR(250)",
	    package_name = "CHAR(250)CHAR(250)",
	    package_prefix = "CHAR(250)",
	    package_url = "CHAR(250)",
	    package_version = "CHAR(250)",
	    package_compat = "CHAR(250)"
	} };


sql.database:insert { string into, col1name = string col1value, col2name = string col2value }
	Add new rows of data into a table in the database.

.. code-block:: lua

	sqldb:insert { into = 'lua_packages',
	    package_name = 'mypackage', 
	    package_description = 'Nuevo paquete',
	    package_date = '2018-10-07',
	    package_version = '1.0.0',
	};

sql.database:update { string package_name, where = string WhereConditional, set = { col1name = col1value } }
	Used to modify the existing records in a table. 
	You must use WHERE clause with UPDATE query to update selected rows to prevent all the rows would be updated.



.. code-block:: lua

	sqldb:update { 'lua_packages', 
	    where = "package_name like 'mypackage'",
	    set = { package_description = 'Es una nueva version mucho mejor que las anteriores.' }
	}


sql.database:select { from = string table_name , string col1name, string col2value, ... }
	Fetch the data from a SQL database table which returns data in the 
	form of a result table. These result tables are also called result 
	sets.

	**Returns:** "select" is an iterator, to fetch data to lua table 
	  use ``sql.database:select_totable`` instead.

.. code-block:: lua

	for row in sqll:select { '*'; from = 'lua_packages' } do
	    print(row.package_name);
	end
