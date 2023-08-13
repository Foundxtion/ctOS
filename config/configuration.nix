{ config, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./boot
    ./network
    ./services
    ./docker
    ./users
    ./location
  ];
  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "23.05";
}
