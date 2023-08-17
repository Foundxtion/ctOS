{config, pkgs, ...}:
let
  secrets = import ../secrets.nix;
in
{
  services.nginx = {
    enable = secrets.services.nginx.enable;
  # TODO: add virtualHosts configuration
    virtualHosts = secrets.services.nginx.virtualHosts;
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = secrets.security.acme.email;
  };
}
