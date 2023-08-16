{ config, pkgs, ... }:
{
  imports = [
    ./foundation.nix
  ];

  users.defaultUserShell = pkgs.zsh;
}
