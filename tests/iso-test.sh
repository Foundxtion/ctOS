#!/bin/sh
cp iso/secrets-template.nix iso/secrets.nix;
nix-build '<nixpkgs/nixos>' -I nixos-config=iso/iso.nix --dry-run && echo "Test1 passed"
