# CLAUDE.md

This repo contains shared MCP server configurations for Claude Code.

## Adding a New MCP

When a user wants to add an MCP, they may provide it in different formats. Parse and handle each:

### 1. Parse the input

**Command format:**
- `claude mcp add name npx package-name` → stdio, name, npx package-name
- `claude mcp add --transport http name https://url.com/mcp` → http, name, url
- `claude mcp add --transport sse name https://url.com/sse` → sse, name, url
- `claude mcp add name -- npx -y package args` → stdio, name, npx -y package args

**JSON format:**
```json
{
  "mcpServers": {
    "server-name": {
      "command": "npx",
      "args": ["package-name", "arg1"]
    }
  }
}
```
→ stdio, server-name, npx package-name arg1

```json
{
  "mcpServers": {
    "server-name": {
      "type": "http",
      "url": "https://example.com/mcp"
    }
  }
}
```
→ http, server-name, url

### 2. Update `install.sh`

Add a new `install_mcp` line in the appropriate section (HTTP MCPs or Stdio MCPs):

```bash
# For HTTP/SSE:
install_mcp "name" "http" "https://url.com/mcp"

# For Stdio:
install_mcp "name" "stdio" "npx" "package-name"
# or with args:
install_mcp "name" "stdio" "npx" "-y" "package-name" "arg1" "arg2"
```

Add a comment above describing what the MCP does (ask the user if unclear).

### 3. Update `README.md`

Add a row to the "Included MCPs" table:

```markdown
| `name` | Type | Description |
```

- Type is `HTTP`, `SSE`, or `Stdio`
- Add `(OAuth)` to description if it's an HTTP MCP that needs authentication
- Keep the table sorted: HTTP MCPs first, then Stdio MCPs

### 4. Run the installer

Run `./install.sh` to verify the MCP installs correctly.

### 5. Commit and push

```bash
git add -A && git commit -m "Add <name> MCP" && git push
```

## Important Notes

- **Ask for description**: If you can't infer what the MCP does from its name/package, ask the user for a brief description before updating files.
- **Verify command runner exists**: Common runners are `npx` (Node.js) and `uvx` (Python/uv). If using something uncommon, mention it may require additional setup.
- **Environment variables**: If the MCP config includes `env` vars, note in the README description that it requires env setup.

## Examples

**Example 1 - Command format:**

User: "add this mcp: claude mcp add stripe npx -y @stripe/mcp"

1. Parse: stdio transport, name=stripe, command=npx -y @stripe/mcp
2. Add to install.sh:
   ```bash
   # Stripe - Payment processing
   install_mcp "stripe" "stdio" "npx" "-y" "@stripe/mcp"
   ```
3. Add to README.md table:
   ```markdown
   | `stripe` | Stdio | Payment processing |
   ```
4. Run `./install.sh`
5. Commit: `git add -A && git commit -m "Add stripe MCP" && git push`

**Example 2 - JSON format:**

User pastes:
```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_TOKEN": "..."
      }
    }
  }
}
```

1. Parse: stdio, name=github, command=npx -y @modelcontextprotocol/server-github, has env vars
2. Add to install.sh:
   ```bash
   # GitHub - Repository access (requires GITHUB_TOKEN env var)
   install_mcp "github" "stdio" "npx" "-y" "@modelcontextprotocol/server-github"
   ```
3. Add to README.md table:
   ```markdown
   | `github` | Stdio | Repository access (requires GITHUB_TOKEN) |
   ```
4. Run `./install.sh`
5. Commit: `git add -A && git commit -m "Add github MCP" && git push`
