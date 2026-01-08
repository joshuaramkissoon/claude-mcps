#!/bin/bash
#
# Claude MCP Global Installer
# Installs all MCPs with --scope user (globally available across all projects)
#
# Usage: ./install.sh
#

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Claude MCP Global Installer${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Helper function to install an MCP
install_mcp() {
  local name="$1"
  local transport="$2"
  shift 2

  # Check if already installed (check ~/.claude.json for user-scope MCPs)
  if grep -q "\"$name\":" ~/.claude.json 2>/dev/null && \
     jq -e ".mcpServers.\"$name\"" ~/.claude.json &>/dev/null; then
    echo -e "${GREEN}✓${NC} $name (already installed)"
    return 0
  fi

  echo -e "${YELLOW}Installing${NC} $name..."

  if [ "$transport" = "http" ]; then
    local url="$1"
    claude mcp add --scope user --transport http "$name" "$url" >/dev/null 2>&1
  elif [ "$transport" = "sse" ]; then
    local url="$1"
    claude mcp add --scope user --transport sse "$name" "$url" >/dev/null 2>&1
  elif [ "$transport" = "stdio" ]; then
    claude mcp add --scope user --transport stdio "$name" -- "$@" >/dev/null 2>&1
  fi

  echo -e "${GREEN}✓${NC} $name installed"
}

echo "Installing MCPs globally (--scope user)..."
echo ""

# ============================================
# HTTP MCPs
# ============================================

# Sentry - Error monitoring and debugging
install_mcp "sentry" "http" "https://mcp.sentry.dev/mcp"

# ============================================
# Stdio MCPs
# ============================================

# Playwright - Browser automation and testing
install_mcp "playwright" "stdio" "npx" "@playwright/mcp@latest"

# Xcode Build MCP - iOS/macOS development
install_mcp "xcodebuildmcp" "stdio" "npx" "-y" "@smithery/cli@latest" "run" "cameroncooke/xcodebuildmcp"

# ============================================
# Add your own MCPs below
# ============================================

# Example: Filesystem MCP
# install_mcp "filesystem" "stdio" "npx" "-y" "@modelcontextprotocol/server-filesystem" "/path/to/allowed/dir"

# Example: GitHub MCP (requires GITHUB_TOKEN env var)
# install_mcp "github" "stdio" "npx" "-y" "@modelcontextprotocol/server-github"

# Example: Postgres MCP (requires DATABASE_URL env var)
# install_mcp "postgres" "stdio" "npx" "-y" "@modelcontextprotocol/server-postgres"

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Installation Complete${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo "Verifying installed MCPs..."
echo ""

# List all MCPs to verify
claude mcp list

echo ""
echo -e "${GREEN}Done!${NC} MCPs are now available globally in all projects."
echo ""
echo "Tips:"
echo "  - Run 'claude mcp list' anytime to see installed MCPs"
echo "  - Run 'claude mcp remove <name> --scope user' to remove one"
echo "  - Add new MCPs to this script and re-run to install"
