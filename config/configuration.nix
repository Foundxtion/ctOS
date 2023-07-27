{ config, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./boot
    ./network
    ./services
    ./docker
    ./users
    ./timezone
  ];
  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "23.05";
}
