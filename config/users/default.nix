{ config, pkgs, ... }:
{
  imports = [
    ./fndx.nix
    ./homeManager.nix
  ];

  users.defaultUserShell = pkgs.zsh;
}
