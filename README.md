# xmr_p2pool.sh

a shell script for automated deployment of [`p2pool`](http://p2pool.io) for [`monero`](https://getmonero.org) mining.

# target platform

`x86-64`

# dependencies

- [`tmux`](https://github.com/tmux/tmux/wiki)
- [`bash`](https://www.gnu.org/software/bash/)

# instructions

```
$ ./xmr_p2pool.sh
```

- wait for `monerod` to finish syncing
- once synced, kill `monerod` via ctrl+c
- exit and kill the `tmux` session
- run `xmr_p2pool.sh` script again
- point XMRig to port 3333

# tested Linux distros

- [x] ubuntu
