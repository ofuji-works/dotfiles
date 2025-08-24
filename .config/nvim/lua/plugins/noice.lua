require("noice").setup({
  -- command line
  cmdline = {
    enabled = true,
    view = "cmdline_popup",
    format = {
      cmdline     = { pattern = "^:",  icon = "",   lang = "vim" },
      search_down = { kind = "search", pattern = "^/",  icon = " ", lang = "regex" },
      search_up   = { kind = "search", pattern = "^%?", icon = " ", lang = "regex" },
      filter      = { pattern = "^:%s*!", icon = "$",   lang = "bash" },
      lua         = { pattern = { "^:%s*lua%s+", "^:%s*lua%s*=%s*", "^:%s*=%s*" }, icon = "", lang = "lua" },
      help        = { name = "help", pattern = "^:%s*he?l?p?%s+", icon = "?" },
    },
  },
  -- messages
  messages = {
    enabled = true,
    view = "mini",
    view_error = "mini",
    view_warn = "mini",
    view_history = "messages",
    view_search = "virtualtext",
  },
  -- LSP
  lsp = {
    progress = { enabled = true, view = "mini" },
    hover = { enabled = true },
    signature = { enabled = true },
    message = { enabled = true, view = "mini" },
  },
  -- Preset
  ---@type NoicePresets
  presets = {
    bottom_search = false, -- use a classic bottom cmdline for search
    command_palette = false, -- position the cmdline and popupmenu together
    long_message_to_split = false, -- long messages will be sent to a split
    inc_rename = false, -- enables an input dialog for inc-rename.nvim
    lsp_doc_border = false, -- add a border to hover docs and signature help
  },
})


