{ config, pkgs, ... }:
let
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/release-23.05.tar.gz";
in
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
    (import "${home-manager}/nixos")
  ];
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  system.stateVersion = "23.05";
}
