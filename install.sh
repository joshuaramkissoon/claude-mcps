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

# Load environment variables from .env file if it exists
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/.env" ]; then
  echo -e "${BLUE}Loading environment variables from .env...${NC}"
  set -a
  source "$SCRIPT_DIR/.env"
  set +a
fi

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Claude MCP Global Installer${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Helper function to install an MCP
# Usage:
#   install_mcp "name" "http" "url"
#   install_mcp "name" "http" "url" --header "Header: Value"
#   install_mcp "name" "stdio" "npx" "package-name" "args..."
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
    shift
    # Check for optional --header flag
    if [ "$1" = "--header" ]; then
      local header="$2"
      claude mcp add --scope user --transport http "$name" "$url" --header "$header" >/dev/null 2>&1
    else
      claude mcp add --scope user --transport http "$name" "$url" >/dev/null 2>&1
    fi
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

# Supabase - Database, auth, storage across all projects
install_mcp "supabase" "http" "https://mcp.supabase.com/mcp"

# Zep Docs - Zep AI memory layer documentation
install_mcp "zep-docs" "http" "https://docs-mcp.getzep.com/mcp"

# RevenueCat - Subscription and in-app purchase management (requires REVENUECAT_API_KEY env var)
install_mcp "revenuecat" "http" "https://mcp.revenuecat.ai/mcp" --header "Authorization: Bearer ${REVENUECAT_API_KEY}"

# ============================================
# Stdio MCPs
# ============================================

# Playwright - Browser automation and testing
install_mcp "playwright" "stdio" "npx" "@playwright/mcp@latest"

# Xcode Build MCP - iOS/macOS development
install_mcp "xcodebuildmcp" "stdio" "npx" "-y" "@smithery/cli@latest" "run" "cameroncooke/xcodebuildmcp"

# iOS Simulator MCP - Simulator control and automation
install_mcp "ios-simulator" "stdio" "npx" "ios-simulator-mcp"

# Fetch - HTTP requests and web content fetching
install_mcp "fetch" "stdio" "uvx" "mcp-server-fetch"

# Chrome DevTools - Browser debugging and inspection
install_mcp "chrome-devtools" "stdio" "npx" "chrome-devtools-mcp@latest"

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
echo -e "${YELLOW}Next step:${NC} If any MCPs show '⚠ Needs authentication' above,"
echo "run this command inside Claude Code to authenticate:"
echo ""
echo -e "  ${BLUE}/mcp${NC}"
echo ""
echo "This will open OAuth flows for MCPs that need it (Supabase, Sentry, etc.)"
echo ""
echo "Tips:"
echo "  - Run 'claude mcp list' anytime to see installed MCPs"
echo "  - Run 'claude mcp remove <name> --scope user' to remove one"
echo "  - Add new MCPs to this script and re-run to install"
