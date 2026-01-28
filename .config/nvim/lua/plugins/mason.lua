require("mason").setup({
  ui = {
    icons = {
      package_installed = "✓",
      package_pending = "➜",
      package_uninstalled = "✗"
    }
  }
})

require("mason-lspconfig").setup({
  automatic_enable = false,
  ensure_installed = {
    "efm",
    "eslint",
--    "golangci_lint_ls",
--    "gopls",
    "lua_ls",
    "rust_analyzer",
    "ts_ls",
    "taplo",
  },
})

