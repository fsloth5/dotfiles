-- Cache the mouse position so as to prevent position
-- to change when the function is called outside of a click
local mouse_row = nil
local mouse_col = nil


_G.StatuslineHandlers = {
	open_lsp_info =
	    function(...)
		    -- Get the screen row where the click occurred
		    if not (mouse_row and mouse_col) then
			    mouse_row = vim.fn.getmousepos().screenrow
			    mouse_col = vim.fn.getmousepos().screencol
		    end

		    -- Create buffer
		    local buf = vim.api.nvim_create_buf(false, true)


		    local width = 50

		    -- Set content
		    vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
			    " LSP Information  ",
			    string.rep("──", width / 2),
			    "Active LSP clients:",
		    })

		    -- Add LSP client names
		    local clients = vim.lsp.get_active_clients({ bufnr = 0 })
		    for _, client in ipairs(clients) do
			    vim.api.nvim_buf_set_lines(buf, -1, -1, false, { "  • " .. client.name })
		    end

		    vim.api.nvim_buf_set_lines(buf, -1, -1, false, { "", "Press 'q' to close" })

		    -- Window dimensions
		    local height = #vim.api.nvim_buf_get_lines(buf, 0, -1, false)

		    local row = mouse_row - height - 3 -- Position above the click

		    local opts = {
			    relative = 'editor',
			    width = width,
			    height = height,
			    row = row,
			    col = mouse_col,
			    style = 'minimal',
			    border = 'rounded',
		    }

		    -- Create window
		    local win = vim.api.nvim_open_win(buf, true, opts)

		    -- Set buffer options
		    vim.api.nvim_buf_set_option(buf, 'modifiable', false)

		    -- Close on 'q' or <Esc>
		    vim.api.nvim_buf_set_keymap(buf, 'n', 'q', ':close<CR>',
			    { noremap = true, silent = true })
		    vim.api.nvim_buf_set_keymap(buf, 'n', '<Esc>', ':close<CR>',
			    { noremap = true, silent = true })
	    end,
}

vim.cmd([[
  function! OpenLspInfo(minwid, clicks, button, modifiers)
    call v:lua.StatuslineHandlers.open_lsp_info(a:minwid, a:clicks, a:button, a:modifiers)
  endfunction]])

-- In your statusline
local function lsp_status()
	local clients = vim.lsp.get_active_clients({ bufnr = 0 })
	if #clients == 0 then
		return ""
	end


	local text = #clients > 1 and " +" .. #clients or "󰣩 " .. clients[1].name
	return "%@OpenLspInfo@" .. text .. "%X"
end

return {
	git = function()
		local git_info = vim.b.gitsigns_status_dict
		if not git_info or git_info.head == "" then
			return ""
		end

		local head    = git_info.head
		local added   = git_info.added and (" + " .. git_info.added) or ""
		local changed = git_info.changed and ("  " .. git_info.changed) or ""
		local removed = git_info.removed and ("  " .. git_info.removed) or ""
		if git_info.added == 0 then added = "" end
		if git_info.changed == 0 then changed = "" end
		if git_info.removed == 0 then removed = "" end

		return table.concat({
			"  ", -- branch icon
			head,
			added, changed, removed,
		})
	end,
	file_type = function()
		local f_type = vim.bo.filetype

		if f_type == "" then return "" end

		local ok, devicons = pcall(require, "nvim-web-devicons")

		if not ok then return "" end

		local icon = devicons.get_icon_by_filetype(f_type)

		if not icon then return "" end

		return icon .. " " .. f_type
	end,

	lsp_name = function()
		-- The second entry is used in case Copilot plugin is present
		local client = vim.lsp.get_active_clients({ bufnr = 0 })[1]
		local client_name = client and client.name or ""
		return (client_name ~= "") and table.concat { "󰣩 ", client_name } or ""
	end,

	lsp_status = lsp_status,
}
