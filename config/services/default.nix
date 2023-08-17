{config, pkgs, ...}:
{
  imports = [
    ./ddclient.nix
    ./nginx.nix
    ./openssh.nix
  ];
}
