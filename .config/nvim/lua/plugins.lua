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
	-- rust
	{
		'rust-lang/rust.vim',
		config = function ()
			vim.g.rustfmt_autosave = 1
		end
	},
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
			vim.api.nvim_exec(
				[[
					augroup my-glyph-palette
  					autocmd! *
  					autocmd FileType fern call glyph_palette#apply()
  					autocmd FileType nerdtree,startify call glyph_palette#apply()
					augroup END
				]],
				false
			)
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
      {
        'lvimuser/lsp-inlayhints.nvim',
        config = true,
      },
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
  	opts = {
    	-- add any options here
  	},
  	dependencies = {
    	-- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
    	"MunifTanjim/nui.nvim",
    	-- OPTIONAL:
    	--   `nvim-notify` is only needed, if you want to use the notification view.
    	--   If not available, we use `mini` as the fallback
    	"rcarriga/nvim-notify",
    }
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
		'simrat39/rust-tools.nvim',
	},
	{
		'jose-elias-alvarez/typescript.nvim',
	},
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
		lazy = false,
		config = function()
			vim.cmd([[colorscheme catppuccin]])
		end
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
		opts = {}
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
