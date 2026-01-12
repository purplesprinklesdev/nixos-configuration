#!/usr/bin/env bash

systemd-inhibit --what=sleep --who="Manual Lock" --why="User manually locked screen" --mode=block sleep infinity &
INHIBIT_PID=$!

# Start temporary swayidle for display management
swayidle \
    timeout 20 'swaymsg "output * dpms off"' \
    resume 'swaymsg "output * dpms on"' &
SWAYIDLE_PID=$!

# Lock the screen
swaylock

# Cleanup: Kill both processes
kill $SWAYIDLE_PID 2>/dev/null
kill $INHIBIT_PID 2>/dev/null
