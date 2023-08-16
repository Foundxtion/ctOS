{ config, pkgs, ... }:
{
  imports = [
    ./systemPackages.nix
    ./programs.nix
  ];
}
