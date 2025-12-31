# NixOS Configuration

## Non-Nix Declarative

Located in `dotfiles`
- waybar
- wofi

## Imperative Changes

#### kline Wifi Network Roaming fix

nmcli connection modify "kline" 802-11-wireless.bssid 3c:37:86:11:31:e0
