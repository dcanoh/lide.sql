--- 0.2.1

local _luasql;

lide.sql = { libs = { luasql = {}, fbclient = {}, alien = {} } };

local isString = lide.error.is_string

local sqldatabase = class 'sqldatabase'

local isString = lide.error.is_string
local sqldatabase = class 'sqldatabase'

-- sqldatabase( database, driver, *username, *password ) --* username and password are optional.
function sqldatabase:sqldatabase( driver, database, username, password )   
         local _env;

         isString(database); isString(driver);
      
      if driver:lower() == 'sqlite3' then
            if lide.sql.libs.luasql[driver] then
               lide.sql.libs.luasql[driver] = lide.sql.libs.luasql[driver];
            else
               -- load luasql.sqlite3 i.e
               lide.sql.libs.luasql[driver] = require ('luasql.' .. driver);
            end

            _luasql = lide.sql.libs.luasql[driver];
         _env = _luasql[driver]();
      
      elseif driver:lower() == 'firebird' then
         isString(username); isString(password);
         local alien = require 'alien' -- v0.5.0

         lide.sql.libs.fbclient = assert(pcall(alien.load, 'fbclient'), 'Firebird 2.5 is not installed now.') -- Verify FBCLIENT.DLL on system.

         if not lide.file.exists(database) then
            fb.create_table(database,username,password);
         end

         local fb  = require 'fbclient.class'
         fb_attach = fb.attach(database, username, password)
      end

      protected {
         database = database,
         driver   = driver,
         env      = _env,
         fb       = fb,
         fb_attach= fb_attach,
      }
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
function sqldatabase:select ( table_query )
   local ret_tbl = {};
   
   local sColumnsToSelect, sTableName, sWhereCond
   sWhereCond = ''

   local tkeywords = { 'from', 'where' }

   for _, keyword in next, tkeywords do
         if not table_query[keyword] then
            if keyword == 'from' then
             error (keyword .. " field is not defined")
         end
         else
            sTableName = sTableName or table_query.from
         if rawget(table_query, 'where') then
               sWhereCond = sWhereCond or (' where ' .. table_query.where)
            end
            table_query[keyword] = nil
         end
   end

   sColumnsToSelect = table.concat(table_query, ',')

   if (self.driver == 'firebird') then
      for st in self.fb_attach:exec ('select ' .. sColumnsToSelect .. ' from ' .. sTableName .. sWhereCond) do
         ret_tbl[#ret_tbl +1] = st:row();
      end

      -- Iterator:
      local i = 0;
      return function ()
         i= i+1;
         return ret_tbl[i]
      end;
   
   elseif (self.driver == 'sqlite3') then
      ret_tbl = self:fetch_query(('select %s from %s'):format(sColumnsToSelect, sTableName .. sWhereCond));

      -- Iterator:
      local i = 0;
      return function ()
         i= i+1;
         return ret_tbl[i]
      end;
   end

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
        tColVals[#tColVals +1] = (c .." = '"..v.."'");
    end

    local sColValsToUpdate = table.concat(tColVals, ',');

   local sql_query = ("UPDATE %s set %s WHERE %s;"):format(SQLTableName, sColValsToUpdate, sWhereCondition or '');
     
   return self:exec(sql_query);

end

function sqldatabase:insert ( tFields )
    local sColumnsToInsert, sValuesToInsert, SQLTableName;
    local tCols, tVals = {}, {};

    SQLTableName = tFields.into;
    tFields.into = nil;

    for c,v in pairs(tFields) do
        tCols[#tCols +1] = c;
        tVals[#tVals +1] = "'"..v.."'";
    end
    
    sColumnsToInsert = table.concat(tCols, ',');
    sValuesToInsert  = table.concat(tVals, ',');
   
   local sql_query = ("INSERT INTO %s ( %s ) VALUES ( %s );"):format(SQLTableName, sColumnsToInsert, sValuesToInsert);

   return self:exec(sql_query);
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

function sqldatabase:exec( query )
   isString(query);

      if (self.driver == 'firebird') then
         return self.fb_attach:exec(query);
      elseif (self.driver == 'sqlite3') then
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
end

lide.sql.database = sqldatabase

return lide.sql