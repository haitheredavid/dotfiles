#!/bin/sh
# 1-minute load average for tmux status bar.
sysctl -n vm.loadavg 2>/dev/null | awk '{print $2}'
