local lspconfig = require("mason-lspconfig")
lspconfig.setup({
  ensure_installed = { "ts_ls", "pyright" },
})
