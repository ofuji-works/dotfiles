-- Window移動設定
vim.keymap.set('n', '<CR><CR>', '<C-w><C-w>', { noremap = true, silent = true, desc = 'Enter連打でWindowを移動' })
--- ターミナルで<c-w>でバッファ操作
vim.api.nvim_set_keymap("t", "<C-w><C-w>", '<C-\\><C-n>', { noremap = true, desc = '[Ctrl+w]連打でノーマルモード' })
vim.api.nvim_set_keymap("t", "<C-w>h", '<C-\\><C-n><C-w>h', { noremap = true, desc = '[Ctrl+w+h]でバッファ移動' })
vim.api.nvim_set_keymap("t", "<C-w>j", '<C-\\><C-n><C-w>j', { noremap = true, desc = '[Ctrl+w+j]でバッファ移動' })
vim.api.nvim_set_keymap("t", "<C-w>k", '<C-\\><C-n><C-w>k', { noremap = true, desc = '[Ctrl+w+k]でバッファ移動' })
vim.api.nvim_set_keymap("t", "<C-w>l", '<C-\\><C-n><C-w>l', { noremap = true, desc = '[Ctrl+w+l]でバッファ移動' })

-- Tab移動設定
vim.keymap.set("n", "<Tab>", "gt", { noremap = true, silent = true })
vim.keymap.set("n", "<S-Tab>", "gT", { noremap = true, silent = true })

-- Color設定
vim.cmd [[
  highlight Normal guibg=none
  highlight NonText guibg=none
]]

-- telescope
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
vim.keymap.set("n", "<leader>fd", "<cmd>Telescope dir live_grep<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>pd", "<cmd>Telescope dir find_files<CR>", { noremap = true, silent = true })

-- Filer
vim.keymap.set('n', '<C-n>', ':Fern ./ -reveal=% -drawer<CR>')

-- LSP
vim.keymap.set('n', 'K',  '<cmd>lua vim.lsp.buf.hover()<CR>', {})
vim.keymap.set('n', 'gf', '<cmd>lua vim.lsp.buf.formatting()<CR>', {})
vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', {})
vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', {})
vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', {})
vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', {})
vim.keymap.set('n', 'gt', '<cmd>lua vim.lsp.buf.type_definition()<CR>', {})
vim.keymap.set('n', 'gn', '<cmd>lua vim.lsp.buf.rename()<CR>', {})
vim.keymap.set('n', 'ga', '<cmd>lua vim.lsp.buf.code_action()<CR>', {})
vim.keymap.set('n', 'ge', '<cmd>lua vim.diagnostic.open_float()<CR>', {})
vim.keymap.set('n', 'g]', '<cmd>lua vim.diagnostic.goto_next()<CR>', {})
vim.keymap.set('n', 'g[', '<cmd>lua vim.diagnostic.goto_prev()<CR>', {})


local function on_cursor_hold()
  vim.diagnostic.open_float()
end

local diagnostic_hover_augroup_name = "lspconfig-diagnostic"
vim.api.nvim_set_option('updatetime', 500)
vim.api.nvim_create_augroup(diagnostic_hover_augroup_name, { clear = true })
vim.api.nvim_create_autocmd({ "CursorHold" }, { group = diagnostic_hover_augroup_name, callback = on_cursor_hold })

-- cmp
vim.opt.completeopt = "menu,menuone,noselect"

-- claude
vim.keymap.set('n', '<leader>cc', '<cmd>ClaudeCode<CR>', { desc = 'Toggle Claude Code' })

