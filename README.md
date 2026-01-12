# Claude MCPs

Shared MCP (Model Context Protocol) server configurations for Claude Code.

MCPs installed from this repo are **global** - they work across all projects on your machine.

## Quick Start

```bash
# Clone the repo
git clone git@github.com:YOUR_USERNAME/claude-mcps.git ~/.claude-mcps

# Run the installer
chmod +x ~/.claude-mcps/install.sh
~/.claude-mcps/install.sh
```

## Updating

When new MCPs are added to the repo:

```bash
cd ~/.claude-mcps && git pull && ./install.sh
```

Already-installed MCPs are skipped (no-op), so it's safe to re-run anytime.

## Included MCPs

| Name | Type | Description |
|------|------|-------------|
| `supabase` | HTTP | Database, auth, storage (OAuth) |
| `sentry` | HTTP | Error monitoring and debugging (OAuth) |
| `playwright` | Stdio | Browser automation and testing |
| `xcodebuildmcp` | Stdio | iOS/macOS Xcode build tools |
| `ios-simulator` | Stdio | iOS Simulator control and automation |
| `fetch` | Stdio | HTTP requests and web content fetching |
| `chrome-devtools` | Stdio | Browser debugging and inspection |

## Adding New MCPs

### Option 1: Use Claude Code (Recommended)

Open Claude Code in this repo and paste the MCP install command or JSON config:

```
"add this mcp: claude mcp add github npx -y @modelcontextprotocol/server-github"
```

or paste JSON:

```
add this mcp:
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"]
    }
  }
}
```

Claude will automatically update `install.sh`, `README.md`, run the installer, and commit/push.

### Option 2: Manual

1. Edit `install.sh`
2. Add a new `install_mcp` line:

```bash
# HTTP MCP
install_mcp "name" "http" "https://url.com/mcp"

# SSE MCP
install_mcp "name" "sse" "https://url.com/sse"

# Stdio MCP
install_mcp "name" "stdio" "npx" "-y" "package-name"
```

3. Update the "Included MCPs" table in this README
4. Run `./install.sh` to test
5. Commit and push
6. Everyone runs `git pull && ./install.sh`

## MCPs Requiring Auth

### OAuth-based MCPs (Supabase, Sentry, etc.)

After running `install.sh`, authenticate OAuth MCPs by running this inside Claude Code:

```
/mcp
```

This opens the OAuth flow in your browser for each MCP that needs it.

### Environment Variable MCPs

Some MCPs need API keys. Set them in your shell profile (`~/.zshrc` or `~/.bashrc`):

```bash
# Example: GitHub MCP
export GITHUB_TOKEN="your-personal-access-token"

# Example: OpenAI
export OPENAI_API_KEY="sk-..."
```

Then add the MCP to `install.sh`:

```bash
install_mcp "github" "stdio" "npx" "-y" "@modelcontextprotocol/server-github"
```

## Manual Management

```bash
# List all installed MCPs
claude mcp list

# Get details for a specific MCP
claude mcp get sentry --scope user

# Remove an MCP
claude mcp remove sentry --scope user

# Add an MCP manually (global)
claude mcp add --scope user --transport http my-mcp https://example.com/mcp
```

## Scopes Explained

- `--scope user` (what we use): Global, available in all projects
- `--scope project`: Stored in `.mcp.json`, shared via git for that repo only
- `--scope local`: Per-project, not shared

## Popular MCPs to Consider

```bash
# File system access
install_mcp "filesystem" "stdio" "npx" "-y" "@modelcontextprotocol/server-filesystem" "$HOME/allowed-dir"

# GitHub integration
install_mcp "github" "stdio" "npx" "-y" "@modelcontextprotocol/server-github"

# PostgreSQL
install_mcp "postgres" "stdio" "npx" "-y" "@modelcontextprotocol/server-postgres"

# SQLite
install_mcp "sqlite" "stdio" "npx" "-y" "@modelcontextprotocol/server-sqlite" "--db" "/path/to/db.sqlite"

# Puppeteer (browser automation)
install_mcp "puppeteer" "stdio" "npx" "-y" "@modelcontextprotocol/server-puppeteer"

# Memory (persistent memory for Claude)
install_mcp "memory" "stdio" "npx" "-y" "@modelcontextprotocol/server-memory"

# Fetch (HTTP requests)
install_mcp "fetch" "stdio" "npx" "-y" "@modelcontextprotocol/server-fetch"
```
