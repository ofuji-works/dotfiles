-- lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  -- neovim
  {
    "folke/neodev.nvim",
    config = function ()
      require("neodev").setup({})
    end
  },
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("tokyonight-night")
    end,
  },
  -- rust
  {
    'rust-lang/rust.vim',
    config = function ()
      vim.g.rustfmt_autosave = 1
    end
  },
  {
    'simrat39/rust-tools.nvim',
  },
  -- fern
  {
    'lambdalisue/fern.vim',
    lazy = false,
    dependencies = {
      { 'lambdalisue/nerdfont.vim' },
      { 'lambdalisue/fern-renderer-nerdfont.vim' },
      { 'lambdalisue/fern-hijack.vim' },
      { 'lambdalisue/glyph-palette.vim' },
      { 'lambdalisue/fern-git-status.vim' },
    },
    config = function()
      vim.g["fern#renderer"] = "nerdfont"
      vim.g["fern#default_hidden"] = 1
      -- Vimscript関数 glyph_palette#apply() を Lua から呼ぶ
      local function apply_glyph_palette()
        vim.fn["glyph_palette#apply"]()
      end

      -- autocmd を Lua API で定義
      local grp = vim.api.nvim_create_augroup("my-glyph-palette", { clear = true })
      vim.api.nvim_create_autocmd("FileType", {
        group = grp,
        pattern = { "fern", "nerdtree", "startify" },
        callback = apply_glyph_palette,
        desc = "Apply glyph-palette on fern/nerdtree/startify",
      })
    end
  },
  {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.2',
    dependencies = {
      'nvim-lua/plenary.nvim',
      {
        'princejoogie/dir-telescope.nvim',
        config = true,
        opts = {
          no_ignore = true,
        }
      }
    },
    build = 'brew install ripgrep fd',
  },
  {
    "williamboman/mason.nvim",
    lazy = false,
  },
  {
    'williamboman/mason-lspconfig.nvim',
    lazy = false,
  },
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      'creativenull/efmls-configs-nvim',
      'lukas-reineke/lsp-format.nvim',
    },
    lazy = false,
  },
  {
    'simeji/winresizer',
    keys = {
      '<c-e>',
    },
  },
  {
    "folke/noice.nvim",
    event = "VeryLazy",
  },
  {
    "hrsh7th/nvim-cmp",
    lazy = false,
    dependencies = {
      { 'hrsh7th/cmp-nvim-lsp' },
      { "hrsh7th/cmp-buffer" },
      { 'hrsh7th/cmp-vsnip' },
      { 'hrsh7th/vim-vsnip' },
      { 'L3MON4D3/LuaSnip' },
      { "saadparwaiz1/cmp_luasnip" },
    },
  },
  {
    'jose-elias-alvarez/typescript.nvim',
  },
  {
    "iamcco/markdown-preview.nvim",
    build = function()
      vim.fn["mkdp#util#install"]()
    end,
    init = function()
      vim.g.mkdp_filetypes = { "markdown" }
    end,
    ft = { "markdown" },
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
  },
  {
    "lewis6991/gitsigns.nvim",
  },
  {
    "sindrets/diffview.nvim",
  },
  {
    "vim-jp/vimdoc-ja",
  },
  {
    "lambdalisue/guise.vim",
    dependencies = {
      "vim-denops/denops.vim",
    },
  },
  {
    "greggh/claude-code.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
  }
})


require("ibl").setup()

require("plugins/nvim-lspconfig");
require("plugins/mason");
require("plugins/noice");
require("plugins/rust-tools");
require("plugins/cmp");
require("plugins/gitsigns");
require("plugins/claude-code");
