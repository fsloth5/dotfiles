LAZY_PLUGIN_SPEC = {}


local function spec(item)
	table.insert(LAZY_PLUGIN_SPEC, { import = item })
end

require("sline.status_line")
