if  not lide.luasql then
	luasql = require 'luasql.sqlite3'
end

local env = luasql.sqlite3()

local sqldatabase = class 'sqldatabase'

function sqldatabase:sqldatabase( database, driver )
	protected {
		database = database,
		driver   = driver,
	}
end

function sqldatabase:exec( query )
	local con = assert(env:connect(self.database));
	local cur = assert(con:execute(query));
	
	print('exec-cur: '..tostring(cur))

	if type(cur) ~= 'number' then
	   cur:close();
	end

	con:close()	
end

local function select( dbConnection, tbName, rowNames, sCond )
	local query, con, res = "select %s from %s %s", env:connect(dbConnection), {}
		
	--print(query:format(rowNames, tbName, sCond or ""))

	local cur = assert(
		con:execute(
		query:format(rowNames, tbName, sCond or "")
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

function sqldatabase:fetch_query ( to_select )	
		local query = to_select
		local con   = env:connect(self.database)
		res = {}
		--print(query:format(rowNames, tbName, sCond or ""))

		local cur = assert(
			con:execute(
				query
				--query:format(rowNames, tbName, sCond or "")
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


-- list of strings: { "a1", "b2" }
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
      )
   end
end

	function sqldatabase:getTables ( ... )
		-- body
	end

	function sqldatabase:createTable ( ... )
		-- body
	end

return sqldatabase
