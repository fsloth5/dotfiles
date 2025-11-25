local plugs = require("sline.plugins")
Statusline = {}

local divider = "  "

function Statusline.active()
	return table.concat {
		plugs.git(),
		divider,
		"%f",
		divider,
		"%=",
		plugs.lsp_name(),
		divider,
		plugs.file_type(),
		divider,
		"%p%% %l:%c "
	}
end

function Statusline.inactive()
	return " %t"
end

local group = vim.api.nvim_create_augroup("Statusline", { clear = true })

vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
	group = group,
	desc = "Activate statusline on focus",
	callback = function()
		vim.opt_local.statusline = "%!v:lua.Statusline.active()"
	end
})

vim.api.nvim_create_autocmd({ "WinLeave", "BufLeave" }, {
	group = group,
	desc = "Deactivate statusline when unfocus",
	callback = function()
		vim.opt_local.statusline = "%!v:lua.Statusline.inactive()"
	end
})
