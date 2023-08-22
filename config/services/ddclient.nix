{config, pkgs, ...}:
let
  secrets = import ../secrets.nix;
  server = import ../machines/server.nix;
in
{
  services.ddclient = {
    enable = true;
    configFile = pkgs.writeText "ddclient-config-file" ''
      use=web, web=${server.ddclient.web}
      protocol=${server.ddclient.protocol}
      server=${server.ddclient.server}
      login=${server.ddclient.login}
      password=${secrets.services.ddclient.password}
      @
    '';
  };
}
