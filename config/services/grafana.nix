{config, pkgs, ...}:
let
  secrets = import ../secrets.nix;
in
{
  services.grafana = {
    enable = secrets.services.grafana.enable;
    settings = secrets.services.grafana.settings;
  };

  services.prometheus = {
    enable = secrets.services.grafana.enable;
    port = 9001;
  };
}
