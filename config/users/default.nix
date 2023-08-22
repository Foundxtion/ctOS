{ config, pkgs, ... }:
{
  imports = [
    ./user.nix
    ./homeManager.nix
  ];

  users.defaultUserShell = pkgs.zsh;
}
