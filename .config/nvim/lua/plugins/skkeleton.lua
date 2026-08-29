-- skkeleton
-- https://github.com/vim-skk/skkeleton
--
-- denops.vim (Deno) 上で動く SKK 日本語入力。Deno は mise で入る。
-- 変換には SKK 辞書が必須。`makers set-skk-dict` (scripts/setting-skk.sh) で
-- L 辞書を ~/.config/skk/SKK-JISYO.L に展開する。約 4.5MB あるため
-- dotfiles には含めない。

local dict_dir = vim.env.XDG_CONFIG_HOME or (vim.env.HOME .. "/.config")
local global_dict = dict_dir .. "/skk/SKK-JISYO.L"

local group = vim.api.nvim_create_augroup("skkeleton_config", { clear = true })

-- 設定は initialize-pre で行う。denops のランタイムは Vim と独立して再起動する
-- ことがあり、その際に設定が飛ぶが、このフックは再実行されるため復元される。
vim.api.nvim_create_autocmd("User", {
  group = group,
  pattern = "skkeleton-initialize-pre",
  callback = function()
    -- <C-j> を skkeleton の乗っ取り対象キーから外す。
    -- 既定では有効中の <C-j> がバッファローカルに再マップされ、SKK 標準の
    -- 「確定 (kakutei)」に消費されてトグルが効かなくなる。外しておくと
    -- 下の toggle マッピングが有効中もそのまま走る。
    vim.g["skkeleton#mapped_keys"] = vim.tbl_filter(function(key)
      return key ~= "<C-j>"
    end, vim.fn["skkeleton#get_default_mapped_keys"]())

    if vim.fn.filereadable(global_dict) == 0 then
      vim.notify(
        "skkeleton: 辞書が見つかりません (" .. global_dict .. ")\n"
          .. "dotfiles で `makers set-skk-dict` を実行してください。",
        vim.log.levels.WARN
      )
      return
    end

    vim.fn["skkeleton#config"]({
      -- エンコーディングは指定しない。L 辞書は EUC-JP だが skkeleton が
      -- EUC-JP / UTF-8 を自動判定する (doc の推奨)。
      globalDictionaries = { global_dict },
      -- 変換中の <CR> は確定だけ行い、改行は入れない。
      eggLikeNewline = true,
      -- カタカナ変換などの結果もユーザー辞書に残す。
      registerConvertResult = true,
    })
  end,
})

-- 辞書ロードで初回入力時にブロックしないよう、denops 側の登録完了を待って
-- 明示的に初期化する (doc FAQ「skkeleton のロード処理が遅い」)。
vim.api.nvim_create_autocmd("User", {
  group = group,
  pattern = "DenopsPluginPost:skkeleton",
  callback = function()
    vim.fn["skkeleton#initialize"]()
  end,
})

-- ローマ字の途中経過で補完メニューが出ると変換の邪魔になるので、
-- skkeleton 有効中はバッファローカルに nvim-cmp を止める。
vim.api.nvim_create_autocmd("User", {
  group = group,
  pattern = "skkeleton-enable-pre",
  callback = function()
    require("cmp").setup.buffer({ enabled = false })
  end,
})

vim.api.nvim_create_autocmd("User", {
  group = group,
  pattern = "skkeleton-disable-post",
  callback = function()
    require("cmp").setup.buffer({ enabled = true })
    -- 無効化時は mode-changed が来ないことがあるので、statusline 用に自分で消す。
    vim.g["skkeleton#mode"] = ""
  end,
})

-- 変換中 (▼) や見出し語入力中 (▽) でも 1 打で無効化する。
-- skkeleton#handle() は opts.key を必ず埋めるため、<Plug>(skkeleton-disable) や
-- <Plug>(skkeleton-toggle) 経由だと denops 側の disable が「キー入力」と見なされ、
-- 直接入力状態以外では確定処理に読み替えられて無効化まで進まない。
-- そのため key を持たない opts で denops を直接叩く。
local function force_disable()
  local ret = vim.fn["denops#request"](
    "skkeleton",
    "handle",
    { "disable", vim.empty_dict(), vim.fn["skkeleton#vim_status"]() }
  )
  vim.g["skkeleton#state"] = ret.state
  -- 未確定文字の確定はバッファへのキー列として返るので流し込む。
  if ret.result ~= "" then
    vim.fn.feedkeys(ret.result, "nit")
  end
  vim.fn["skkeleton#doautocmd"]()
end

vim.keymap.set({ "i", "c" }, "<C-j>", function()
  if vim.g["skkeleton#enabled"] then
    force_disable()
  else
    -- 有効化は denops 未起動でも待ってくれる skkeleton#handle() に任せる。
    vim.fn["skkeleton#handle"]("enable", vim.empty_dict())
  end
end, { desc = "skkeleton: 日本語入力をトグル" })

-- statusline の SKK 表示を即時更新する。
vim.api.nvim_create_autocmd("User", {
  group = group,
  pattern = "skkeleton-mode-changed",
  callback = function()
    vim.cmd("redrawstatus")
  end,
})
