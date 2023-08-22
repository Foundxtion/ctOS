{config, pkgs, ...}:
let
  secrets = import ../secrets.nix;
  server = import ../machines/server.nix;
in
{
  services.nginx = {
    enable = false;
    # TODO: add virtualHosts configuration
    virtualHosts = server.nginx.virtualHosts;
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = secrets.security.acme.email;
  };
}
