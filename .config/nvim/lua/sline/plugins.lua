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
  end
}
