require 'lide.core.init'
lide.sql = require 'lide.sql'

sqll = lide.sql.database ('sqlite3', 'testx.db')

sqll:create_table { lua_packages = {  
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
    package_name = 'base64', 
    package_description = 'First package_description.',
    package_date = '2018-10-07',
    package_version = '1.0.0',
};
--

sqll:update { 'lua_packages', 
    where = "package_name like 'base64'",
    set = { package_description = 'Second package_description.' }
}

-- Since 0.2 select is an iterator and you can refer to select_table to 
-- return table.
for row in sqll:select { '*'; from = 'lua_packages' } do
    print(row.package_name, row.package_version)
    print('\t' .. row.package_description)
end
