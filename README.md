# NixOS Configuration

## Non-Nix Declarative

Located in `dotfiles`
- waybar
- wofi

## Imperative Changes

#### kline Wifi Network Roaming fix

`nmcli connection modify "kline" 802-11-wireless.bssid 3c:37:86:11:31:e0`

#### Bluetooth not showing up twice on waybar

Go to blueman-manager --> View --> Plugins --> Turn off system icon

#### Git Commit Signing

`git config --global user.signingkey /PATH/TO/.SSH/KEY.PUB`
