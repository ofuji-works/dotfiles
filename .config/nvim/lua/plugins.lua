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
    opts = {
      ensure_installed = {
        "efm",
        "eslint",
        "eslint_d",
        "golangci-lint",
        "golangci_lint_ls",
        "gopls",
        "lua_ls",
        "markdownlint",
        "prettier",
        "rubocop",
        "rust_analyzer",
        "standardjs",
        "stylelint",
        "ts-standard",
        "tsserver",
      }
    }
	},
	{
		'neovim/nvim-lspconfig',
		dependencies = { 
      'creativenull/efmls-configs-nvim',
      {
        'lvimuser/lsp-inlayhints.nvim',
        config = true,
      },
    },
		config = function ()
			local lspconfig = require('lspconfig')
			local util = require('lspconfig/util')
			local capabilities = require('cmp_nvim_lsp').default_capabilities()

			lspconfig.rust_analyzer.setup {
				filetypes = {"rust"},
				capabilities = capabilities,
				root_dir = util.root_pattern("Cargo.toml"),
				settings = {
    			['rust-analyzer'] = {
						cargo = {
							allFeatures = true
						},
            check = {
              command = "clippy"
            }
					},
  			},
			}

      lspconfig.gopls.setup {
        on_attach = function(client, bufnr)
          require("lsp-inlayhints").on_attach(client, bufnr)
        end,
        cmd = {"gopls"},
        filetypes = {"go", "gomod", "gowork", "gotmpl"},
        root_dir = util.root_pattern("go.work", "go.mod", ".git"),
        settings = {
          gopls = {
            completeUnimported = true,
            usePlaceholders = true,
            analyses = {
              unusedparams = true,
            },
            hints = {
              assignVariableTypes = true,
              compositeLiteralFields = true,
              compositeLiteralTypes = true,
              constantValues = true,
              functionTypeParameters = true,
              parameterNames = true,
              rangeVariableTypes = true,
            },
          },
        }
      }

			lspconfig.tsserver.setup {
        on_attach = function(client, bufnr)
          require("lsp-inlayhints").on_attach(client, bufnr)
        end,

        settings = {
          typescript = {
            inlayHints = {
              includeInlayParameterNameHints = 'all',
              includeInlayParameterNameHintsWhenArgumentMatchesName = false,
              includeInlayFunctionParameterTypeHints = true,
              includeInlayVariableTypeHints = true,
              includeInlayVariableTypeHintsWhenTypeMatchesName = false,
              includeInlayPropertyDeclarationTypeHints = true,
              includeInlayFunctionLikeReturnTypeHints = true,
              includeInlayEnumMemberValueHints = true,
            }
          },
          javascript = {
            inlayHints = {
              includeInlayParameterNameHints = 'all',
              includeInlayParameterNameHintsWhenArgumentMatchesName = false,
              includeInlayFunctionParameterTypeHints = true,
              includeInlayVariableTypeHints = true,
              includeInlayVariableTypeHintsWhenTypeMatchesName = false,
              includeInlayPropertyDeclarationTypeHints = true,
              includeInlayFunctionLikeReturnTypeHints = true,
              includeInlayEnumMemberValueHints = true,
            }
          }
        }
      }
			lspconfig.eslint.setup {}

			local eslint = require('efmls-configs.linters.eslint')
			local prettier = require('efmls-configs.formatters.prettier')
			local languages = {
  			typescript = { eslint, prettier },
        typescriptreact = { eslint, prettier },
  			lua = { stylua },
			}
			lspconfig.efm.setup {
        root_dir = util.root_pattern('package.json', '.eslintrc', '.git'),
				filetypes = vim.tbl_keys(languages),
				init_options = { documentFormatting = true },
				settings = {
					languages = languages,
				},
			}

			local lsp_fmt_group = vim.api.nvim_create_augroup('LspFormattingGroup', {})
			vim.api.nvim_create_autocmd('BufWritePost', {
			  group = lsp_fmt_group,
			  callback = function(ev)
			    local efm = vim.lsp.get_active_clients({ name = 'efm', bufnr = ev.buf })
			
			    if vim.tbl_isempty(efm) then
			      return
			    end
			
			    vim.lsp.buf.format({ name = 'efm' })
			  end,
			})

		end,
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
  	"github/copilot.vim",
		config = function()
			vim.g.copilot_filetypes = {
				markdown = true,
				yaml = true,
			}
		end,
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
})

