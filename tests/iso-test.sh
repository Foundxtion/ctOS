#!/bin/sh
cp settingsTemplates/isoSettings.nix ./settings.nix
nix-build '<nixpkgs/nixos>' -A config.system.build.isoImage -I nixos-config=settings.nix --dry-run && echo "Test passed !" && rm ./settings.nix;
