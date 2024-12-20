#!/bin/bash

source env.sh

# monerod bootstrap
if [ ! -d "$XMR_DIR" ]; then
  echo "fetching $XMR_URL..."
  wget $XMR_URL
  echo ""
  echo "unpacking $XMR_TARBALL..."
  tar xvf $XMR_TARBALL
else
 echo "\$XMR_DIR detected, skipping fetch/unpack"
fi


# p2pool bootstrap
if [ ! -d "$P2POOL_DIR" ]; then
  echo "fetching $P2POOL_URL..."
  wget $P2POOL_URL
  echo ""
  echo "unpacking $P2POOL_TARBALL..."
  tar xvf $P2POOL_TARBALL
else
  echo "\$P2POOL_DIR detected, skipping fetch/unpack"
fi

# xmrig bootstrap
if [ ! -d "$XMRIG_DIR" ]; then
  echo "fetching $XMRIG_URL..."
  wget $XMRIG_URL
  echo ""
  echo "unpacking $XMRIG_TARBALL"
  tar xvf $XMRIG_TARBALL
else
  echo "\$XMRIG_DIR detected, skipping fetch/unpack"
fi

# make sure tmux is available
if ! command -v tmux 2>&1 >/dev/null; then
  echo "tmux could not be found, please install it."
  exit 1
fi

# start new tmux session detached
tmux new-session -d -s "$TMUX_SESSION"

# run monerod in the first (default) pane
tmux send-keys -t "$TMUX_SESSION:0.0" "$XMR_CMD" C-m

# split the window horizontally
tmux split-window -h -t "$TMUX_SESSION:0"

# run p2pool in second pane
tmux send-keys -t "$TMUX_SESSION:0.1" "$P2POOL_CMD" C-m

# split the window
tmux split-window -v -t "$TMUX_SESSION:0"

# run xmrig in third pane
tmux send-keys -t "$TMIX_SESSION:0.2" "$XMRIG_CMD" C-m

# attach to the tmux session
tmux attach -t "$TMUX_SESSION"