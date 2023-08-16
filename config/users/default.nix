{ config, pkgs, ... }:
{
  imports = [
    ./foundation.nix
    ./homeManager.nix
  ];

  users.defaultUserShell = pkgs.zsh;
}
