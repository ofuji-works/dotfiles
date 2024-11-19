local lspconfig = require('lspconfig')
local util = require('lspconfig/util')
local capabilities = require('cmp_nvim_lsp').default_capabilities()
local inlay_hints = require('lsp-inlayhints')

on_attach = function(client, bufnr)
  inlay_hints.on_attach(client, bufnr)
end

local same_settings_servers = {
  "html",
  "cssls",
  "svelte",
  "eslint",
  "vuels",
  "taplo",
}

for _, lsp in ipairs(same_settings_servers) do
  lspconfig[lsp].setup({
    on_attach = on_attach,
    capabilities = capabilities,
  })
end

-- Lua
lspconfig.lua_lsp.setup({
  on_attach = on_attach,
  capabilities = capabilities,
})

-- Rust
lspconfig.rust_analyzer.setup({
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
      },
    },
  },
})

-- Go
go_hints_options = {
  assignVariableTypes = true,
  compositeLiteralFields = true,
  compositeLiteralTypes = true,
  constantValues = true,
  functionTypeParameters = true,
  parameterNames = true,
  rangeVariableTypes = true,
}
lspconfig.gopls.setup({
  on_attach = on_attach,
  capabilities = capabilities,
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
      hints = go_hints_options,
    },
  }
})

-- TypeScript
---- eslint
---- prettier
--
inlay_hints_options = {
  includeInlayParameterNameHints = 'all',
  includeInlayParameterNameHintsWhenArgumentMatchesName = false,
  includeInlayFunctionParameterTypeHints = true,
  includeInlayVariableTypeHints = true,
  includeInlayVariableTypeHintsWhenTypeMatchesName = false,
  includeInlayPropertyDeclarationTypeHints = true,
  includeInlayFunctionLikeReturnTypeHints = true,
  includeInlayEnumMemberValueHints = true,
}
lspconfig.tsserver.setup({
  on_attach = on_attach,
  capabilities = capabilities,
  settings = {
    typescript = {
      inlayHints = inlay_hints_options,
    },
    javascript = {
      inlayHints = inlay_hints_options,
    }
  }
})

local eslint_linter = require('efmls-configs.linters.eslint_d')
local rubocop = require('efmls-configs.linters.rubocop')

local eslint_formatter = require('efmls-configs.formatters.eslint_d')
local prettier = require('efmls-configs.formatters.prettier')
local rome = require('efmls-configs.formatters.rome')
local stylua = require('efmls-configs.formatters.stylua')
local goimports = require('efmls-configs.formatters.goimports')
local stylelint = require('efmls-configs.formatters.stylelint')

ts_opt = {
  eslint_linter,
  eslint_formatter,
  prettier,
  rome,
  stylelint,
}

local languages = {
  go = { goimports },
  ruby = { rubocop },
  javascript = ts_opt,
  typescript = ts_opt,
  typescriptreact = ts_opt,
  css = { stylelint },
  scss = { stylelint },
  sass = { stylelint },
  less = { stylelint },
  lua = { stylua },
}

lspconfig.efm.setup({
  on_attach = require('lsp-format').on_attach,
  filetypes = vim.tbl_keys(languages),
  init_options = { documentFormatting = true },
  settings = {
    languages = languages,
  },
})

