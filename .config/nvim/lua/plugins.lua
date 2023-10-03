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
		lazy = false,
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
		lazy = false,
    dependencies = { 'nvim-lua/plenary.nvim' }, 
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
		config = function ()
			local lspconfig = require('lspconfig')
			local util = "lspconfig/util"
			local capabilities = require('cmp_nvim_lsp').default_capabilities()

			lspconfig.rust_analyzer.setup {
				filetypes = {"rust"},
				capabilities = capabilities,
				-- root_dir = util.root_pattern("Cargo.toml"),
 	 			settings = {
    			['rust-analyzer'] = {
						cargo = {
							allFeatures = true
						}
					},
  			},
			}

			lspconfig.tsserver.setup {}

		end,
		lazy = false,
	},
	{
		'simeji/winresizer',
		keys = {
			'<c-e>',
		},
		lazy = false,
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
			{ 'L3MON4D3/LuaSnip' },
			{ "saadparwaiz1/cmp_luasnip" },
		},
	},
	{
		'simrat39/rust-tools.nvim',
		lazy = false,
	},
	{
		'jose-elias-alvarez/typescript.nvim',
		lazy = false,
	},
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
		lazy = false,
	}
})

