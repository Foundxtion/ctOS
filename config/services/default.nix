{config, pkgs, ...}:
let
  secrets = import ../secrets.nix;
in
{
  services.openssh = {
    enable = secrets.services.openssh.enable;
    settings.PermitRootLogin = secrets.services.openssh.PermitRootLogin;
  };

  services.nginx = {
    enable = secrets.services.nginx.enable;
    # TODO: add virtualHosts configuration
    virtualHosts = secrets.services.nginx.virtualHosts;
  };

  services.ddclient = secrets.ddclient;
}
