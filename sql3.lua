require 'lide.core.init'
sqldatabase = require 'sqldatabase'

-- list of strings: { "a1", "b2" }
function sqldatabase:select_borrar ( tCols )
   local sColumnsToSelect, sTableName, sWhereCond

   local tkeywords = { 'from', 'where' }   
   
   for _, keyword in next, tkeywords do
      if not tCols[keyword] then
         if keyword == 'from' then
             error (keyword .. " field is not defined.")
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
      ) 
   else
      error 'no hay columnas???'
   end
end

--function sqldatabase:update ( sTableName, tColumns, tValues )
  -- sqll:exec 'UPDATE'   

--end-


sqll = sqldatabase('test.db', 'sqlite3')
ret = sqll:exec "insert into lua_packages"


--table.foreach(sqll:select { from = 'lua_packages', 'a1','sw2', 'xd4',  where = 'package_name like "asdf"' }[1], print)
----
--for i,v in pairs ( sqll:select { from = 'lua_packages', 'package_name' }) do
--   table.foreach(v, print)
--end

--sqll:select { '*' , from = 'thetable'}
--table.foreach(sqll:select 'package_description' [1], print)

