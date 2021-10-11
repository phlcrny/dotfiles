#!/bin/bash
Session='Pwsh'
SessionExists=$(tmux list-sessions | grep $Session)

if [ "$SessionExists" == "" ]; then
    tmux new-session -s $Session -d
    tmux send-keys 'pwsh -NoLogo' C-m 'clear' C-m
    tmux split-window -v
    tmux send-keys 'pwsh -NoLogo' C-m 'clear' C-m
fi

tmux attach -t $Session