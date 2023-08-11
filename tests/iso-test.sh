#!/bin/sh

cp -r builder/src/iso tmp
mv tmp/secrets-template.nix tmp/secrets.nix
nix-build '<nixpkgs/nixos>' -I nixos-config=tmp/iso.nix --dry-run
