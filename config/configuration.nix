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

  system.stateVersion = "23.05";
}
