#!/bin/sh
cp iso/secrets-template.nix iso/secrets.nix;
nix-build '<nixpkgs/nixos>' -I nixos-config=iso/iso.nix --dry-run && rm iso/secrets.nix && echo "Test passed !"
