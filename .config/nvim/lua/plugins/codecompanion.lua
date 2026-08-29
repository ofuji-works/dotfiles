-- codecompanion.nvim
-- https://codecompanion.olimorris.dev/installation
--
-- Adapter: Claude Code over ACP (Agent Client Protocol).
-- Requires the Zed ACP bridge on $PATH:
--   npm install -g @agentclientprotocol/claude-agent-acp
-- 認証は既存の Claude Code ログイン (~/.claude/.credentials.json) を再利用するため
-- 追加設定は不要。CI など未ログイン環境では `claude setup-token` で取得した値を
-- 環境変数 CLAUDE_CODE_OAUTH_TOKEN に入れれば adapter が拾う。
--
-- NOTE: :CodeCompanionCmd (cmd interaction) は HTTP adapter 専用のため未設定。

require("codecompanion").setup({
  adapters = {
    acp = {
      -- codecompanion v19 の env 解決は、環境変数が未設定のとき変数名そのものを
      -- 値として子プロセスに渡してしまう。結果 Bearer に "CLAUDE_CODE_OAUTH_TOKEN"
      -- という文字列が乗り 401 になる。関数にすると未設定時は nil になり、
      -- ACP ブリッジが ~/.claude/.credentials.json へフォールバックする。
      claude_code = function()
        return require("codecompanion.adapters").extend("claude_code", {
          env = {
            CLAUDE_CODE_OAUTH_TOKEN = function()
              return os.getenv("CLAUDE_CODE_OAUTH_TOKEN")
            end,
          },
        })
      end,
    },
  },
  interactions = {
    -- Chat buffer: :CodeCompanionChat
    chat = {
      adapter = "claude_code",
    },
    -- Inline edits: :CodeCompanion <prompt>
    inline = {
      adapter = "claude_code",
    },
    -- Raw CLI in a terminal split: :CodeCompanionCLI
    cli = {
      agent = "claude_code",
      agents = {
        claude_code = {
          cmd = "claude",
          args = {},
          description = "Claude Code CLI",
          provider = "terminal",
        },
      },
      opts = {
        auto_insert = true,
      },
    },
  },
  display = {
    chat = {
      window = {
        layout = "vertical",
        position = "right",
        width = 0.4,
        -- 既定 (breakindent/linebreak/wrap) は deep merge で残る。
        -- グローバルの number が効いてしまうのでチャットだけ切る。
        opts = {
          number = false,
          relativenumber = false,
        },
      },
    },
  },
  opts = {
    language = "Japanese",
    log_level = "ERROR", -- "DEBUG" / "TRACE" when troubleshooting
  },
})

local function notify(title, body, urgency)
  local cmd
  if vim.fn.has("mac") == 1 and vim.fn.executable("osascript") == 1 then
    cmd = {
      "osascript", "-e",
      string.format("display notification %q with title %q sound name %q", body, title, "Glass"),
    }
  elseif vim.fn.executable("notify-send") == 1 then
    cmd = { "notify-send", "-u", urgency or "normal", title, body }
  else
    return
  end
  vim.system(cmd, { detach = true })
end

-- 送信フィードバック --------------------------------------------------------
-- ACP アダプタは最初のトークンが返るまで数秒かかることがあり、送信が通ったのか
-- 画面から判別できない。チャットウィンドウの winbar にスピナー + 状態 + 経過秒を
-- 出して「今どこで待っているか」を可視化する。
-- laststatus=3 (グローバル statusline) なので、per-window に出せるのは winbar だけ。

vim.api.nvim_set_hl(0, "CodeCompanionProgress", { link = "DiagnosticInfo", default = true })

local spinner = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }

-- wins: winbar を書き換えたウィンドウ -> 元の winbar 値
local progress = { timer = nil, bufnr = nil, label = "", started = 0, frame = 0, wins = {} }

local function progress_render()
  local frame = spinner[(progress.frame % #spinner) + 1]
  local sec = math.floor((vim.uv.now() - progress.started) / 1000)
  local text = string.format("%%#CodeCompanionProgress# %s %s (%d秒)%%*", frame, progress.label, sec)
  -- チャットウィンドウは応答中に閉じて開き直せるので、毎 tick 走査して拾い直す
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_buf(win) == progress.bufnr then
      if progress.wins[win] == nil then
        progress.wins[win] = vim.wo[win].winbar
      end
      vim.wo[win].winbar = text
    end
  end
end

local function progress_stop()
  if progress.timer then
    progress.timer:stop()
    progress.timer:close()
    progress.timer = nil
  end
  for win, saved in pairs(progress.wins) do
    if vim.api.nvim_win_is_valid(win) then
      vim.wo[win].winbar = saved
    end
  end
  progress.wins = {}
  progress.bufnr = nil
end

local function progress_start(bufnr, label)
  progress_stop()
  progress.bufnr = bufnr
  progress.label = label
  progress.started = vim.uv.now()
  progress.frame = 0
  progress_render()
  progress.timer = vim.uv.new_timer()
  progress.timer:start(100, 100, vim.schedule_wrap(function()
    if not progress.bufnr or not vim.api.nvim_buf_is_valid(progress.bufnr) then
      return progress_stop()
    end
    progress.frame = progress.frame + 1
    progress_render()
  end))
end

-- 走っているときだけラベルを差し替える。経過秒はターン開始からの通算にしたいので
-- リセットしない。bufnr が一致しないイベント (inline / 別チャット) は無視される。
local function progress_label(bufnr, label)
  if progress.bufnr and progress.bufnr == bufnr then
    progress.label = label
    progress_render()
  end
end

local ai_group = vim.api.nvim_create_augroup("ai_notify", { clear = true })

vim.api.nvim_create_autocmd("User", {
  group = ai_group,
  pattern = "CodeCompanionChatSubmitted",
  callback = function(args)
    progress_start(args.data.bufnr, "送信しました — 応答待ち")
  end,
})

-- 最初のトークンが届いたら「待ち」から「応答中」へ。ツール呼び出しを挟むと
-- 1 ターンで複数リクエストが飛ぶので、その都度ラベルが往復する。
vim.api.nvim_create_autocmd("User", {
  group = ai_group,
  pattern = "CodeCompanionRequestStreaming",
  callback = function(args) progress_label(args.data.bufnr, "応答中") end,
})

vim.api.nvim_create_autocmd("User", {
  group = ai_group,
  pattern = "CodeCompanionToolsStarted",
  callback = function(args) progress_label(args.data.bufnr, "ツール実行中") end,
})

vim.api.nvim_create_autocmd("User", {
  group = ai_group,
  pattern = "CodeCompanionChatDone",
  callback = function()
    local sec = progress.bufnr and math.floor((vim.uv.now() - progress.started) / 1000) or nil
    progress_stop()
    notify("Claude — 返答が来ました", sec and ("待ち時間 " .. sec .. "秒") or "", "low")
  end,
})

-- ツールの実行許可を求められたとき（こちらの方が気づきたい）
vim.api.nvim_create_autocmd("User", {
  group = ai_group,
  pattern = "CodeCompanionToolApprovalRequested",
  callback = function(args)
    progress_label(args.data.bufnr, "承認待ち")
    notify("Claude — 承認を待っています", "ツールの実行許可が必要です", "critical")
  end,
})

-- 失敗も知らせる（黙って止まると待ち続けてしまう）
-- NOTE: CodeCompanionChatToolFailure は User イベントではなくハイライト群の名前なので
-- パターンに入れても発火しない。中断は ChatStopped で拾う。
vim.api.nvim_create_autocmd("User", {
  group = ai_group,
  pattern = "CodeCompanionChatStopped",
  callback = function(args)
    progress_stop()
    notify("Claude — 中断/失敗", tostring(args.match), "critical")
  end,
})
