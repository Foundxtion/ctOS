#!/bin/sh
cp settings/devSettings.nix settings/settings.nix
cp tests/hardware-configuration.nix .;
nix-build '<nixpkgs/nixos>' -I nixos-config=configuration.nix --dry-run && echo "Test passed !";

rm settings/settings.nix hardware-configuration.nix;

