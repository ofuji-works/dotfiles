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

local ai_group = vim.api.nvim_create_augroup("ai_notify", { clear = true })
local pending = {}   -- どのイベントが「待ち」を開始したかを覚える

vim.api.nvim_create_autocmd("User", {
  group = ai_group,
  pattern = "CodeCompanionChatSubmitted",
  callback = function() pending.chat = vim.uv.now() end,
})

vim.api.nvim_create_autocmd("User", {
  group = ai_group,
  pattern = "CodeCompanionChatDone",
  callback = function()
    local sec = pending.chat and math.floor((vim.uv.now() - pending.chat) / 1000) or nil
    pending.chat = nil
    notify("Claude — 返答が来ました", sec and ("待ち時間 " .. sec .. "秒") or "", "low")
  end,
})

-- ツールの実行許可を求められたとき（こちらの方が気づきたい）
vim.api.nvim_create_autocmd("User", {
  group = ai_group,
  pattern = "CodeCompanionToolApprovalRequested",
  callback = function()
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
    pending.chat = nil
    notify("Claude — 中断/失敗", tostring(args.match), "critical")
  end,
})
