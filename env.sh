#!/bin/bash

XMR_VERSION="0.18.3.4"
XMR_RELEASE="monero-linux-x64-v$XMR_VERSION"
XMR_TARBALL="$XMR_RELEASE.tar.bz2"
XMR_URL="https://downloads.getmonero.org/cli/$XMR_TARBALL"
XMR_DIR="monero-x86_64-linux-gnu-v$XMR_VERSION"

XMR_BIN=$XMR_DIR/monerod

XMR_ZMQ_PORT=18083
XMR_ZMQ_BIND="tcp://127.0.0.1:$XMR_ZMQ_PORT"

XMR_RPC_PORT=18081
XMR_RPC_IP="127.0.0.1"

XMR_CMD="./$XMR_BIN --zmq-pub $XMR_ZMQ_BIND --rpc-bind-ip $XMR_RPC_IP --rpc-bind-port $XMR_RPC_PORT --db-salvage --prune-blockchain"

P2POOL_VERSION="4.2"
P2POOL_RELEASE="p2pool-v$P2POOL_VERSION-linux-x64"
P2POOL_TARBALL="$P2POOL_RELEASE.tar.gz"

P2POOL_URL="https://github.com/SChernykh/p2pool/releases/download/v$P2POOL_VERSION/$P2POOL_TARBALL"
P2POOL_DIR="$P2POOL_RELEASE"

P2POOL_BIN=$P2POOL_DIR/p2pool

DEFAULT_XMR_ADDR="47f1qTtTPfLX7bB4BziNqQREVT4cZySWFL8A7Md8yKzr5mcL82UKRKBTesQzvEQEwD3eB6BWNvgvk81MJQEfaXJA1K1Ca3d"

XMRIG_VERSION=6.22.2
XMRIG_TARBALL="xmrig-$XMRIG_VERSION-linux-static-x64.tar.gz"

XMRIG_URL="https://github.com/xmrig/xmrig/releases/download/v$XMRIG_VERSION/$XMRIG_TARBALL"

XMRIG_DIR="xmrig-$XMRIG_VERSION"
XMRIG_BIN="$XMRIG_DIR/xmrig"

XMRIG_N_THREADS=2

is_monerod_synced() {
    # Retrieve info from monerod
    INFO=$(curl -s http://127.0.0.1:18081/json_rpc \
            -d '{"jsonrpc":"2.0","id":"0","method":"get_info"}' \
            -H 'Content-Type: application/json')

    # Extract the synchronized value
    SYNCHRONIZED=$(echo "$INFO" | jq -r '.result.synchronized')

    if [ "$SYNCHRONIZED" = "true" ]; then
        return 0  # true, synced
    else
        return 1  # false, not synced
    fi
}

p2pool_start() {
  source env.sh
  read -p "Which address do you want to mine to? (default: $DEFAULT_XMR_ADDR) " XMR_ADDR
  XMR_ADDR=${XMR_ADDR:-$DEFAULT_XMR_ADDR}
  P2POOL_START="./$P2POOL_BIN --host 127.0.0.1 --zmq-port $XMR_ZMQ_PORT --rpc-port $XMR_RPC_PORT --wallet $XMR_ADDR"
  if is_monerod_synced; then
     # echo $P2POOL_START
      exec $P2POOL_START
  else
      echo "cannot start p2pool because monerod is still syncing... wait until it finishes, then kill this tmux session and run the script again"
  fi
}

xmrig_start()
{
  source env.sh
  if is_monerod_synced; then
    ./$XMRIG_BIN -o "127.0.0.1:3333" -t $XMRIG_N_THREADS
  else
    echo "cannot start xmrig because monerod is still syncing... wait until it finishes, then kill this tmux session and run the script again"
  fi
}

TMUX_SESSION="xmr_p2pool"

P2POOL_CMD="source env.sh; sleep 5; p2pool_start"

XMRIG_CMD="source env.sh; sleep 10; xmrig_start"
