#!/bin/sh
cp settings/serverSettings.nix settings/settings.nix
cp tests/hardware-configuration.nix entrypoint;
nix-build '<nixpkgs/nixos>' -I nixos-config=entrypoint/configuration.nix --dry-run && echo "Test passed !";

rm settings/settings.nix entrypoint/hardware-configuration.nix;

