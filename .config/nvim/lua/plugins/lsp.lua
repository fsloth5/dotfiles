vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "single" })

vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = "single" })

local signs = {
	ERROR = '',
	WARN = '',
	HINT = '',
	INFO = '',
}

for _, type in ipairs({ "Error", "Warn", "Info", "Hint" }) do
	local hl = "DiagnosticSign" .. type
	local hl2 = "Diagnostic" .. type
	vim.fn.sign_define(hl, { text = signs[type:upper()], texthl = hl2, numhl = hl2 })
end

vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
	vim.lsp.diagnostic.on_publish_diagnostics,
	{
		virtual_text = false,
		signs = true,
		update_in_insert = false,
		underline = true,
	}
)

local my_capabilities = vim.lsp.protocol.make_client_capabilities()

my_capabilities.textDocument.completion.completionItem.snippetSupport = true

my_capabilities.textDocument.completion.completionItem.documentationFormat = {
	"markdown", "plaintext"
}

my_capabilities.textDocument.completion.completionItem.snippetSupport = true
my_capabilities.textDocument.completion.completionItem.preselectSupport = true
my_capabilities.textDocument.completion.completionItem.insertReplaceSupport = true
my_capabilities.textDocument.completion.completionItem.labelDetailsSupport = true
my_capabilities.textDocument.completion.completionItem.deprecatedSupport = true
my_capabilities.textDocument.completion.completionItem.commitCharactersSupport = true
my_capabilities.textDocument.completion.completionItem.tagSupport = {
	valueSet = { 1 }
}
my_capabilities.textDocument.completion.completionItem.resolveSupport = {
	properties = { "documentation", "detail", "additionalTextEdits" }
}

my_capabilities = require('cmp_nvim_lsp').default_capabilities(my_capabilities)

local lsp_utils = require "conf_utils.lsp"

local servers = lsp_utils.servers

for _, lsp in pairs(servers) do
	local default_config = vim.lsp.config[lsp]

	default_config.on_attach = lsp_utils.on_attach

	local default_capabilities = default_config.capabilities

	default_config.capabilities = default_capabilities and
	    vim.tbl_deep_extend('force', default_config.capabilities, my_capabilities) or my_capabilities

	local overridden = nil

	if lsp == "bashls" then
		overridden = lsp_utils.bashls_config
	elseif lsp == "clangd" then
		overridden = lsp_utils.clangd_config
	elseif lsp == "denols" then
		overridden = lsp_utils.denols_config
	elseif lsp == "emmet_ls" then
		overridden = lsp_utils.emmet_ls_config
	elseif lsp == "hls" then
		overridden = lsp_utils.hls_config
	elseif lsp == "lua_ls" then
		overridden = lsp_utils.lua_ls
	elseif lsp == "ts_ls" then
		overridden = lsp_utils.ts_ls_config
	elseif lsp == "purescriptls" then
		overridden = lsp_utils.purescriptls_config
	elseif lsp == "sourcekit" then
		overridden = lsp_utils.sourcekit_config
	end

	vim.lsp.config(lsp, overridden and vim.tbl_deep_extend('force', default_config, overridden) or default_config)

	vim.lsp.enable(lsp)
end
