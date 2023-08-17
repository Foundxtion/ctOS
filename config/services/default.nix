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

  services.ddclient = {
    enable = secrets.services.ddclient.enable;
    configFile = pkgs.writeText "ddclient-config-file" ''
        use=web, web=${secrets.services.ddclient.web}
        protocol=${secrets.services.ddclient.protocol}
        server=${secrets.services.ddclient.server}
        login=${secrets.services.ddclient.login}
        password=${secrets.services.ddclient.password}
        @
    '';
  };
}
