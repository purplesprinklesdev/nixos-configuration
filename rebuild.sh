#!/usr/bin/env bash
# RUN AS SUDO

set -e

echo "Would you like to run garbage collection?"
read -e ans
if [ $ans = y ]; then
	echo "Delete older than how many days?"
	read -e days
	nix-collect-garbage --delete-older-than ${days}d
	echo "Old Generations removed"
fi

sudo -u $SUDO_USER git diff -U0 .

echo "NixOS Rebuilding..."


nixos-rebuild switch --flake . &>nixos-switch.log || (cat nixos-switch.log | grep --color error && false)

echo "Rebuild Success!"
echo "Would you like to commit?"
read -e ans
if [ $ans = y ]; then
	echo "Commit name:"
	read -e name
	gen="$(nixos-rebuild list-generations | grep True | awk '{print $1;}')"
	sudo -u $SUDO_USER git commit -am "$name - $HOSTNAME Gen $gen"
fi

sudo -u $SUDO_USER nixos-rebuild list-generations | cat
