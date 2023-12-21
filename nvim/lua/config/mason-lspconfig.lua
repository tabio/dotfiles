local lspconfig = require("mason-lspconfig")
lspconfig.setup({
  ensure_installed = { "tsserver", "pyright" },
})
