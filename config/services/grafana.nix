{config, pkgs, ...}:
let
  secrets = import ../secrets.nix;
in
{
  services.grafana = {
    enable = secrets.services.grafana.enable;
    settings = secrets.services.grafana.settings;
  };
}
