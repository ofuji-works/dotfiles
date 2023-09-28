vim.cmd [[packadd packer.nvim]]

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
		 },
		 config = function()
			vim.api.nvim_exec(
			 	[[
					let g:fern#renderer = "nerdfont"
					let g:fern#default_hidden = 1 
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
		},
	}
})

