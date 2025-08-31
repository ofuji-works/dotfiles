-- Color設定
vim.cmd [[
  highlight Normal guibg=none
  highlight NonText guibg=none
]]

-- TrueColor を有効化
vim.o.termguicolors = true
-- Normal 背景を透明に
vim.api.nvim_set_hl(0, "Normal", { bg = "NONE" })
vim.api.nvim_set_hl(0, "NormalNC", { bg = "NONE" }) -- 非アクティブウィンドウも透明に
