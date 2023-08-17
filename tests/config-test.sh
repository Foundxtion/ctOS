#!/bin/sh
cp iso/secrets-template.nix config/secrets.nix;
nixos-generate-config --show-hardware-config > config/hardware-configuration.nix;
nix-build '<nixpkgs/nixos>' -I nixos-config=config/configuration.nix --dry-run;

rm config/secrets.nix config/hardware-configuration.nix;

echo "Test passed !";
