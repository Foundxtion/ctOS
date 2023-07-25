{ config, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./boot
    ./network
    ./services
    ./docker
    ./users
  ];
  nixpkgs.config.allowUnfree = true;
}
