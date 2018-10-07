require 'lide.core.init'
sqldatabase = require 'sqldatabase'

sqll = sqldatabase('testx.db', 'sqlite3')



sqll:create { lua_packages = {  
    package_checksum = "Text",
    package_date = "Text",
    package_description = "Text",
    package_name = "Text",
    package_prefix = "Text",
    package_url = "Text",
    package_version = "Text",
    package_compat = "Text"
} };


ret = sqll:insert { into = 'lua_packages',
    package_name = 'casqueta', 
    package_description = 'acabe de echarme dos perco',
    package_date = '2018-10-07',
    package_version = '1.0.0',
};
--

print(sqll:update { 'lua_packages', 
    where = "package_name like 'casqueta'",
    set = { package_description = 'su manifestacion de ese sueño ya paso.' }
})

-- table.foreach(sqll:select { from = 'lua_packages', 'a1','sw2', 'xd4',  where = 'package_name like "asdf"' }[1], print)
----
for i,v in pairs ( sqll:select { from = 'lua_packages', 'package_name' }) do
   table.foreach(v, print)
end

--sqll:select { '*' , from = 'thetable'}
--table.foreach(sqll:select 'package_description' [1], print)

