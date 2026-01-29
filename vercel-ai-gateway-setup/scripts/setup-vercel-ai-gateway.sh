#!/usr/bin/env bash
#
# Vercel AI Gateway Setup for Claude Code
# ----------------------------------------
# This script configures Claude Code to route requests
# through Vercel AI Gateway for monitoring and observability.
#
# Usage: Run this script via the Claude Code skill, or directly:
#   bash setup-vercel-ai-gateway.sh
#
# Named arguments (for non-interactive / Claude Code invocation):
#   --mode apikey|max    Setup mode: "apikey" or "max" (Claude Max)
#   --keychain           Store API key in macOS Keychain (macOS only)
#   --no-keychain        Do not use macOS Keychain
#   --confirm            Auto-confirm appending to shell config
#   --logout             Auto-confirm Claude Code logout (API key mode)
#   --no-logout          Skip Claude Code logout
#
# Examples:
#   bash setup-vercel-ai-gateway.sh --mode apikey --keychain --confirm
#   bash setup-vercel-ai-gateway.sh --mode max --no-keychain --confirm
#
# IMPORTANT: This script never asks for or handles API keys directly.
# It generates the shell configuration lines that YOU paste into your
# shell profile, entering your own key in the appropriate place.

set -euo pipefail

# ── Parse named arguments ─────────────────────────────────────
ARG_MODE=""
ARG_KEYCHAIN=""
ARG_CONFIRM=""
ARG_LOGOUT=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --mode)
      ARG_MODE="$2"
      shift 2
      ;;
    --keychain)
      ARG_KEYCHAIN="yes"
      shift
      ;;
    --no-keychain)
      ARG_KEYCHAIN="no"
      shift
      ;;
    --confirm)
      ARG_CONFIRM="yes"
      shift
      ;;
    --logout)
      ARG_LOGOUT="yes"
      shift
      ;;
    --no-logout)
      ARG_LOGOUT="no"
      shift
      ;;
    *)
      echo "Unknown argument: $1"
      exit 1
      ;;
  esac
done

BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m'

info()  { echo -e "${BLUE}[info]${NC}  $*"; }
ok()    { echo -e "${GREEN}[ok]${NC}    $*"; }
warn()  { echo -e "${YELLOW}[warn]${NC}  $*"; }
err()   { echo -e "${RED}[error]${NC} $*"; }

# ── Detect shell config file ────────────────────────────────────
detect_shell_config() {
  local shell_name
  shell_name="$(basename "$SHELL")"
  case "$shell_name" in
    zsh)  echo "$HOME/.zshrc" ;;
    bash)
      if [[ -f "$HOME/.bash_profile" ]]; then
        echo "$HOME/.bash_profile"
      else
        echo "$HOME/.bashrc"
      fi
      ;;
    *)    echo "$HOME/.profile" ;;
  esac
}

SHELL_CONFIG="$(detect_shell_config)"

# ── Check prerequisites ─────────────────────────────────────────
check_claude_installed() {
  if ! command -v claude &>/dev/null; then
    err "Claude Code CLI not found. Install it first:"
    echo "  npm install -g @anthropic-ai/claude-code"
    exit 1
  fi
  ok "Claude Code CLI found: $(command -v claude)"
}

# ── Choose setup mode ───────────────────────────────────────────
choose_mode() {
  if [[ -n "$ARG_MODE" ]]; then
    case "$ARG_MODE" in
      apikey|max) MODE="$ARG_MODE" ;;
      *)
        err "Invalid --mode value: $ARG_MODE (expected 'apikey' or 'max')"
        exit 1
        ;;
    esac
    info "Mode: $MODE"
    return
  fi

  echo ""
  echo -e "${BOLD}Choose your setup mode:${NC}"
  echo ""
  echo "  1) API Key mode    – Use a Vercel AI Gateway API key"
  echo "  2) Claude Max mode – Use your Claude Code Max subscription"
  echo "                       through the gateway (observability only)"
  echo ""
  read -rp "Enter 1 or 2: " MODE_CHOICE
  case "$MODE_CHOICE" in
    1) MODE="apikey" ;;
    2) MODE="max" ;;
    *)
      err "Invalid choice. Please run the script again."
      exit 1
      ;;
  esac
}

# ── macOS keychain helper ────────────────────────────────────────
ask_keychain() {
  USE_KEYCHAIN=false
  if [[ "$(uname -s)" == "Darwin" ]]; then
    if [[ "$ARG_KEYCHAIN" == "yes" ]]; then
      USE_KEYCHAIN=true
      info "Using macOS Keychain for key storage."
      return
    elif [[ "$ARG_KEYCHAIN" == "no" ]]; then
      info "Skipping macOS Keychain."
      return
    fi

    echo ""
    read -rp "Store the API key in macOS Keychain for extra security? (y/N): " KC
    if [[ "$KC" =~ ^[Yy]$ ]]; then
      USE_KEYCHAIN=true
    fi
  fi
}

# ── Generate config lines (API Key mode) ────────────────────────
generate_apikey_config() {
  local marker="# --- Vercel AI Gateway for Claude Code ---"

  if $USE_KEYCHAIN; then
    cat <<BLOCK

$marker
export ANTHROPIC_BASE_URL="https://ai-gateway.vercel.sh"
export ANTHROPIC_AUTH_TOKEN=\$(security find-generic-password -a "\$USER" -s "ANTHROPIC_AUTH_TOKEN" -w)
export ANTHROPIC_API_KEY=""
$marker
BLOCK
  else
    cat <<BLOCK

$marker
export ANTHROPIC_BASE_URL="https://ai-gateway.vercel.sh"
export ANTHROPIC_AUTH_TOKEN="<YOUR_AI_GATEWAY_API_KEY>"
export ANTHROPIC_API_KEY=""
$marker
BLOCK
  fi
}

# ── Generate config lines (Claude Max mode) ─────────────────────
generate_max_config() {
  local marker="# --- Vercel AI Gateway for Claude Code (Max) ---"

  if $USE_KEYCHAIN; then
    cat <<BLOCK

$marker
export ANTHROPIC_BASE_URL="https://ai-gateway.vercel.sh"
export ANTHROPIC_CUSTOM_HEADERS="x-ai-gateway-api-key: Bearer \$(security find-generic-password -a "\$USER" -s "ANTHROPIC_AUTH_TOKEN" -w)"
$marker
BLOCK
  else
    cat <<BLOCK

$marker
export ANTHROPIC_BASE_URL="https://ai-gateway.vercel.sh"
export ANTHROPIC_CUSTOM_HEADERS="x-ai-gateway-api-key: Bearer <YOUR_AI_GATEWAY_API_KEY>"
$marker
BLOCK
  fi
}

# ── Keychain storage instructions ────────────────────────────────
print_keychain_instructions() {
  echo ""
  warn "Before sourcing your shell config, store your key in Keychain:"
  echo ""
  echo -e "  ${BOLD}security add-generic-password -a \"\$USER\" -s \"ANTHROPIC_AUTH_TOKEN\" \\${NC}"
  echo -e "  ${BOLD}  -w \"<YOUR_AI_GATEWAY_API_KEY>\"${NC}"
  echo ""
  echo "  To update the key later:"
  echo ""
  echo -e "  ${BOLD}security add-generic-password -U -a \"\$USER\" -s \"ANTHROPIC_AUTH_TOKEN\" \\${NC}"
  echo -e "  ${BOLD}  -w \"<NEW_KEY>\"${NC}"
}

# ── Write to shell config ───────────────────────────────────────
write_config() {
  local config_lines="$1"
  local marker_pattern="Vercel AI Gateway for Claude Code"

  # Check if config already exists
  if grep -q "$marker_pattern" "$SHELL_CONFIG" 2>/dev/null; then
    warn "Existing Vercel AI Gateway config found in $SHELL_CONFIG."
    read -rp "Overwrite it? (y/N): " OVERWRITE
    if [[ "$OVERWRITE" =~ ^[Yy]$ ]]; then
      # Remove old block (between marker lines)
      local tmp
      tmp="$(mktemp)"
      awk -v pat="$marker_pattern" '
        $0 ~ pat { skip = !skip; next }
        !skip { print }
      ' "$SHELL_CONFIG" > "$tmp"
      mv "$tmp" "$SHELL_CONFIG"
      info "Removed old config block."
    else
      info "Keeping existing config. No changes made."
      return 1
    fi
  fi

  echo "$config_lines" >> "$SHELL_CONFIG"
  ok "Configuration appended to $SHELL_CONFIG"
  return 0
}

# ── Logout from Claude Code ─────────────────────────────────────
maybe_logout() {
  if [[ "$MODE" == "apikey" ]]; then
    if [[ "$ARG_LOGOUT" == "yes" ]]; then
      claude /logout 2>/dev/null || true
      ok "Logged out of Claude Code."
      return
    elif [[ "$ARG_LOGOUT" == "no" ]]; then
      info "Skipping Claude Code logout."
      return
    fi

    echo ""
    read -rp "Log out of Claude Code now? (recommended for API key mode) (Y/n): " LO
    if [[ ! "$LO" =~ ^[Nn]$ ]]; then
      claude /logout 2>/dev/null || true
      ok "Logged out of Claude Code."
    fi
  fi
}

# ── Main ─────────────────────────────────────────────────────────
main() {
  echo ""
  echo -e "${BOLD}╔══════════════════════════════════════════════════╗${NC}"
  echo -e "${BOLD}║   Vercel AI Gateway – Claude Code Setup          ║${NC}"
  echo -e "${BOLD}╚══════════════════════════════════════════════════╝${NC}"
  echo ""

  check_claude_installed
  choose_mode
  ask_keychain

  local config_lines
  if [[ "$MODE" == "apikey" ]]; then
    config_lines="$(generate_apikey_config)"
  else
    config_lines="$(generate_max_config)"
  fi

  echo ""
  info "The following will be added to ${BOLD}$SHELL_CONFIG${NC}:"
  echo "$config_lines"

  if [[ "$ARG_CONFIRM" != "yes" ]]; then
    echo ""
    read -rp "Append to $SHELL_CONFIG? (Y/n): " CONFIRM
    if [[ "$CONFIRM" =~ ^[Nn]$ ]]; then
      info "Aborted. You can add the lines manually."
      exit 0
    fi
  else
    info "Auto-confirming append to $SHELL_CONFIG"
  fi

  if write_config "$config_lines"; then
    if $USE_KEYCHAIN; then
      print_keychain_instructions
    else
      echo ""
      warn "Open ${BOLD}$SHELL_CONFIG${NC} and replace ${BOLD}<YOUR_AI_GATEWAY_API_KEY>${NC}"
      warn "with your actual Vercel AI Gateway API key."
    fi

    maybe_logout

    echo ""
    info "Reload your shell config:"
    echo -e "  ${BOLD}source $SHELL_CONFIG${NC}"
    echo ""
    info "Then start Claude Code:"
    echo -e "  ${BOLD}claude${NC}"
    echo ""
    ok "Setup complete. Your requests will route through Vercel AI Gateway."
  fi
}

main "$@"
