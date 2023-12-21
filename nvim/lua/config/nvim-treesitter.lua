local configs = require("nvim-treesitter.configs")

configs.setup({
  ensure_installed = { "typescript", "javascript", "html", "tsx", "lua", "python", "json", "jsonnet", "yaml", "ssh_config", "sql" },
  sync_install = false,
  highlight = { enable = true },
  indent = { enable = true },
})
