local _luasql;

lide.sql = { libs = { luasql = {} } };

local isString = lide.error.is_string

local sqldatabase = class 'sqldatabase'

function sqldatabase:sqldatabase( database, driver )   
   isString(database); isString(driver);

   if lide.sql.libs.luasql[driver] then
      lide.sql.libs.luasql[driver] = lide.sql.libs.luasql[driver];
   else
      -- load luasql.sqlite3 i.e
      lide.sql.libs.luasql[driver] = require ('luasql.' .. driver);
   end

   _luasql = lide.sql.libs.luasql[driver];

	protected {
		database = database,
		driver   = driver,
      env      = _luasql[driver]();
	}

end

function sqldatabase:exec( query )
	local con = assert(self.env:connect(self.database));
	local cur = assert(con:execute(query));
	local ret_cursor;

	if type(cur) == 'number' then
		ret_cursor = cur;
		con:close();
		
		return ret_cursor;
	else
		ret_cursor = cur;
	   cur:close();
		con:close();
	    
	   return ret_cursor;
	end
end

function sqldatabase:fetch_query ( to_select )	
		local query = to_select
		local con   = self.env:connect(self.database)
		res = {}

		local cur = assert(
			con:execute(
				query
		))
		
		local row = cur:fetch ({}, "a")
		while row do
			local this = #res+1
			res[this] = {}
			for rowname, rowvalue in pairs(row) do
				res[this][rowname] = rowvalue
			end
			row = cur:fetch ({}, "a")
		end
		cur:close()
		con:close()
		return res
end


-- list of strings sqldatabase:select { "a1", "b2" from = 'lua_packages' };
function sqldatabase:select ( tCols )
   local sColumnsToSelect, sTableName, sWhereCond

   local tkeywords = { 'from', 'where' }

   for _, keyword in next, tkeywords do
      if not tCols[keyword] then
         if keyword == 'from' then
             error (keyword .. " field is not defined")
         end
      else
         sTableName = sTableName or tCols.from
         sWhereCond = sWhereCond or tCols.where
         tCols[keyword] = nil
      end
   end

   sColumnsToSelect = table.concat(tCols, ',')

   if sColumnsToSelect then
      return self:fetch_query(
        ('select %s from %s'):format(sColumnsToSelect, sTableName)
      );
   end
end

function sqldatabase:insert ( tFields )
    local sColumnsToInsert, sValuesToInsert, SQLTableName;
    local tCols, tVals = {}, {};

    SQLTableName = tFields.into;
    tFields.into = nil;

    for c,v in pairs(tFields) do
        tCols[#tCols +1] = c;
        tVals[#tVals +1] = '"'..v..'"';
    end
    
    sColumnsToInsert = table.concat(tCols, ',');
    sValuesToInsert  = table.concat(tVals, ',');

    return self:exec (("INSERT INTO %s ( %s ) VALUES ( %s );"):format(SQLTableName, sColumnsToInsert, sValuesToInsert));
end

function sqldatabase:update ( tFields )
    local sColumnsToInsert, sWhereCondition, SQLTableName;
    local tColVals = {};

    if not tFields.where or not tFields[1] then
        error 'lide.sql.sqldatabase: params error read api reference.';
    end

    SQLTableName    = tFields[1];
    sWhereCondition = tFields.where
    tFields[1] = nil;
    tFields.where = nil;

    for c,v in pairs(tFields.set) do
        tColVals[#tColVals +1] = (c ..' = "'..v..'"');
    end

    sColValsToUpdate = table.concat(tColVals, ',');
    
    return self:exec(
        ("UPDATE %s set %s WHERE %s;"):format(SQLTableName, sColValsToUpdate, sWhereCondition or '')
    );
end

function sqldatabase:create_table ( tFields )
    local SQLTableName, sColValsToCreate;
    local tColVals = {};

    for table_name , columns in pairs(tFields) do
        for c,v in pairs(columns) do
            tColVals[#tColVals +1] = ('"'.. c ..'" '.. v);
        end 
        SQLTableName = table_name;
        sColValsToCreate = table.concat(tColVals, ',');        
        break;
    end

    return self:exec (('CREATE TABLE "%s"( %s ); '):format(SQLTableName, sColValsToCreate));
end

lide.sql.database = sqldatabase

return lide.sql