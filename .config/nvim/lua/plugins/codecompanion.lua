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
      },
    },
  },
  opts = {
    language = "Japanese",
    log_level = "ERROR", -- "DEBUG" / "TRACE" when troubleshooting
  },
})
