{ config, pkgs, ... }:
{
  imports = [
    ./boot
    ./docker
    ./environment
    ./hardware-configuration.nix
    ./location
    ./network
    ./services
    ./users
  ];
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  system.stateVersion = "23.05";
}
