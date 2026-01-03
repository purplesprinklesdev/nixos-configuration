#!/usr/bin/env bash

set -e

echo "Would you like to run garbage collection?"
read -e ans
if [ $ans = y ]; then
	echo "Delete older than how many days?"
	read -e days
	nix-collect-garbage --delete-older-than ${days}d
	echo "Old Generations removed"
fi

git diff -U0 .

echo "NixOS Rebuilding..."


nixos-rebuild switch --flake . &>nixos-switch.log || (cat nixos-switch.log | grep --color error && false)

echo "Rebuild Success!"
echo "Would you like to commit?"
read -e ans
if [ $ans = y ]; then
	echo "Commit name:"
	read -e name
	git commit -am "$name"
fi

nixos-rebuild list-generations | cat
