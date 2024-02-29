local actions = require('telescope.actions')
require("telescope").setup({
  defaults = {
    mappings = {
      i = {
        ["<CR>"] = actions.select_default,
      },
    },
  },
  extensions = {
    -- ソート性能を大幅に向上させるfzfを使う
    fzf = {
      fuzzy = true,
      override_generic_sorter = true,
      override_file_sorter = true,
      case_mode = "smart_case",
    },
  },
})
