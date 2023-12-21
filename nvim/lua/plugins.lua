return {
  {
    "EdenEast/nightfox.nvim",
    config = function()
      vim.cmd([[colorscheme nightfox]])
    end
  },
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('config/lualine')
    end
  },
  {
    'numToStr/Comment.nvim',
    config = function()
      require('Comment').setup()
    end
  },
  {
    'nvim-tree/nvim-tree.lua',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('config/nvim-tree')
      vim.api.nvim_set_keymap('n', '<C-e>', ':NvimTreeToggle<CR>', {silent=true})
    end
  },
  {
    'nvim-telescope/telescope.nvim', tag = '0.1.5',
    dependencies = { 'nvim-lua/plenary.nvim', 'nvim-telescope/telescope-fzf-native.nvim' },
    config = function()
      require('config/telescope')
      vim.api.nvim_set_keymap('n', '<Leader>ff', ":Telescope find_files <CR>", {})
      vim.api.nvim_set_keymap('n', '<Leader>fg', ":Telescope live_grep <CR>", {})
      vim.api.nvim_set_keymap('n', '<Leader>fk', ":Telescope keymaps <CR>", {})
    end
  },
  {
    "nvim-telescope/telescope-file-browser.nvim",
    dependencies = { "nvim-telescope/telescope.nvim" },
    config = function()
      vim.api.nvim_set_keymap('n', '<Leader>fb', ":Telescope file_browser <CR>", {noremap = true})
    end
  },
  {
    'windwp/nvim-autopairs',
    event = "InsertEnter",
    opts = {}
  },
  {
    "nvim-treesitter/nvim-treesitter", -- syntax highlight
    build = ":TSUpdate",
    config = function ()
      require("config/nvim-treesitter")
    end
  },
  {
    'rcarriga/nvim-notify',
    config = function()
      require("config/nvim-notify")
    end
  },
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = {},
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    }
  },
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-nvim-lua",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "saadparwaiz1/cmp_luasnip",
      "L3MON4D3/LuaSnip",
    },
    config = function()
      require("config/nvim-cmp")
    end
  },
  {
    "williamboman/mason.nvim",
    build = ":MasonUpdate",
    opts = {},
  },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = {
      { "williamboman/mason.nvim" , "neovim/nvim-lspconfig" },
    },
    config = function()
      require("config/mason-lspconfig")
    end
  }
}
