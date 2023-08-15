{config, pkgs, ...}:
let
  secrets = import ../secrets.nix;
in
{
  services.openssh = {
    enable = secrets.services.openssh.enable;
    passwordAuthentication = false;
    kbdInteractiveAuthentication = false;
    permitRootLogin = secrets.services.openssh.permitRootLogin;
  };

  services.nginx = {
    enable = secrets.services.nginx.enable;
    # TODO: add virtualHosts configuration
    virtualHosts = secrets.services.nginx.virtualHosts;
  };

  services.ddclient = secrets.services.ddclient;
}
