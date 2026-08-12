#!/usr/bin/env bash
set -euo pipefail

HOSTNAME="cloud-workstation"
SESSION_NAME="workspace"

echo "==> Configuring Tailscale SSH with static hostname: ${HOSTNAME}..."
sudo tailscale up --hostname="${HOSTNAME}" --ssh --reset

TAILSCALE_IP=$(tailscale ip -4 || true)

echo "=================================================="
echo "  CLOUD WORKSTATION READY FOR MOBILE SSH"
echo "  Tailscale Hostname : ${HOSTNAME}"
echo "  Tailscale IP       : ${TAILSCALE_IP}"
echo "  SSH Target         : runner@${HOSTNAME}"
echo "=================================================="

# Configure low-latency settings for tmux
tmux set-option -g escape-time 10 2>/dev/null || true
tmux set-option -g focus-events on 2>/dev/null || true

# Create default workspace session if missing
if ! tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    tmux new-session -d -s "$SESSION_NAME" -n "shell"
    tmux new-window -t "${SESSION_NAME}:1" -n "dev"
    tmux new-window -t "${SESSION_NAME}:2" -n "logs"
    tmux select-window -t "${SESSION_NAME}:0"
fi

# Auto-attach to tmux upon SSH login
DEFAULT_SHELL_CONFIG="${HOME}/.bashrc"
AUTO_ATTACH_CMD='if [ -z "$TMUX" ] && [ -n "$SSH_CONNECTION" ]; then tmux attach-session -t workspace || tmux new-session -s workspace; fi'

if ! grep -q "tmux attach-session" "$DEFAULT_SHELL_CONFIG" 2>/dev/null; then
    echo "" >> "$DEFAULT_SHELL_CONFIG"
    echo "# Auto-attach to tmux on SSH login" >> "$DEFAULT_SHELL_CONFIG"
    echo "$AUTO_ATTACH_CMD" >> "$DEFAULT_SHELL_CONFIG"
fi

echo "Listening for incoming Termius SSH connections..."
while true; do
    sleep 60
done
