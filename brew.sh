#!/bin/bash
# =============================================================================
# Backwards Compatibility Wrapper
# =============================================================================
# This script wraps setup.sh for backwards compatibility.
# For new usage, prefer: ./setup.sh
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "💡 Note: brew.sh now calls setup.sh"
echo "   For direct usage, run: ./setup.sh"
echo ""

exec "$SCRIPT_DIR/setup.sh" "$@"
