#!/usr/bin/env bash
set -euo pipefail

# 1. Fetch Tailscale IPv4 Address
TAILSCALE_IP=$(tailscale ip -4 || true)

if [[ -z "$TAILSCALE_IP" ]]; then
    echo "ERROR: Tailscale IP not found. Ensure Tailscale action connected properly."
    exit 1
fi

PORT=7681
SESSION_NAME="workspace"

echo "=================================================="
echo "  CLOUD WORKSTATION TERMINAL READY"
echo "  Access via Tailscale: http://${TAILSCALE_IP}:${PORT}"
echo "=================================================="

# 2. Setup tmux layout if session does not exist
if ! tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    tmux new-session -d -s "$SESSION_NAME" -n "shell"
    tmux new-window -t "${SESSION_NAME}:1" -n "dev"
    tmux new-window -t "${SESSION_NAME}:2" -n "logs"
    tmux select-window -t "${SESSION_NAME}:0"
fi

# 3. Bind ttyd strictly to the Tailscale IP on Port 7681
# Using 'tmux attach-session' ensures reconnecting doesn't kill background tasks
exec ttyd \
    --port "$PORT" \
    --interface "$TAILSCALE_IP" \
    --writable \
    tmux attach-session -t "$SESSION_NAME"

