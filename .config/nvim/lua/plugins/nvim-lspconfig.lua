local lspconfig = require('lspconfig')
local util = require('lspconfig/util')
local capabilities = require('cmp_nvim_lsp').default_capabilities()

local function enable_inlay_hints(bufnr)
  local ih = vim.lsp.inlay_hint
  if type(ih) == "function" then
    ih(bufnr, true) -- Neovim 0.9 系
  elseif type(ih) == "table" and type(ih.enable) == "function" then
    ih.enable(true, { bufnr = bufnr }) -- Neovim 0.10+
  end
end

local function toggle_inlay_hints(bufnr)
  local ih = vim.lsp.inlay_hint
  if type(ih) == "function" then
    -- 0.9 系は自前で状態を持つ
    local enabled = vim.b.__ih_enabled or false
    ih(bufnr, not enabled)
    vim.b.__ih_enabled = not enabled
  elseif type(ih) == "table" and ih.is_enabled and ih.enable then
    local enabled = ih.is_enabled({ bufnr = bufnr })
    ih.enable(not enabled, { bufnr = bufnr })
  end
end

local on_attach = function(client, bufnr)
  if client.server_capabilities.inlayHintProvider then
    enable_inlay_hints(bufnr)
    vim.keymap.set("n", "<leader>ih", function() toggle_inlay_hints(bufnr) end,
      { buffer = bufnr, desc = "Toggle Inlay Hints" })
  end
end

local same_settings_servers = {
  "html",
  "cssls",
  "svelte",
  "eslint",
  "vuels",
  "taplo",
  "lua_ls",
}

for _, lsp in ipairs(same_settings_servers) do
  lspconfig[lsp].setup({
    on_attach = on_attach,
    capabilities = capabilities,
  })
end

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
local go_hints_options = {
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
local inlay_hints_options = {
  includeInlayParameterNameHints = 'all',
  includeInlayParameterNameHintsWhenArgumentMatchesName = false,
  includeInlayFunctionParameterTypeHints = true,
  includeInlayVariableTypeHints = true,
  includeInlayVariableTypeHintsWhenTypeMatchesName = false,
  includeInlayPropertyDeclarationTypeHints = true,
  includeInlayFunctionLikeReturnTypeHints = true,
  includeInlayEnumMemberValueHints = true,
}
lspconfig.ts_ls.setup({
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


--- Lint / Format

---- linters 
local eslint_linter = require('efmls-configs.linters.eslint_d')
local rubocop = require('efmls-configs.linters.rubocop')

---- formatter
local eslint_formatter = require('efmls-configs.formatters.eslint_d')
local prettier = require('efmls-configs.formatters.prettier')
local rome = require('efmls-configs.formatters.rome')
local stylua = require('efmls-configs.formatters.stylua')
local goimports = require('efmls-configs.formatters.goimports')
local stylelint = require('efmls-configs.formatters.stylelint')

local ts_opt = {
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

