#!/bin/sh
cp iso/secrets-template.nix config/secrets.nix;
cp tests/hardware-configuration.nix config;
nix-build '<nixpkgs/nixos>' -I nixos-config=config/configuration.nix --dry-run && echo "Test passed !";

rm config/secrets.nix config/hardware-configuration.nix;

