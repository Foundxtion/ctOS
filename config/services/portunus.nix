{config, pkgs, ...}:
let
  secrets = import ../secrets.nix;
  server = import ../machines/server.nix;
in
{
  services.portunus = {
    enable = true;

    ldap = {
      tls = true;
      suffix = server.ldap.suffix;
    };

    port = server.portunus.port;
    domain = server.portunus.domain;
  };

  systemd.services.portunus = {
    after = ["acme-${server.portunus.domain}.service"];
  };
}
