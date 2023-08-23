{config, pkgs, ...}:
{
  imports = [
    ./ddclient.nix
    ./grafana.nix
    ./mailserver.nix
    ./nginx.nix
    ./openssh.nix
    ./portunus.nix
  ];
}
