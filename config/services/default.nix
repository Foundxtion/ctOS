{config, pkgs, ...}:
{
  imports = [
    ./ddclient.nix
    ./grafana.nix
    ./nginx.nix
    ./openssh.nix
  ];
}
