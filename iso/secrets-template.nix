{
  git-remote = "";
  hostName = "";
  network = {
    hasStaticAddress = false;
    ipAddress = "";
    prefixLength = 0;
    defaultGateway = "";
  };
  authorizedKey = "";
  services = {
    openssh = {
      enable = false;
      permitRootLogin = "no";
    };
    nginx = {
      enable = false;
      virtualHosts = {
        # Here will be written all nginx virtualHosts config
      };
    };
    security.acme = {
      email = "";
    };
    ddclient = {
      enable = false;
      protocol = "";
      web = "";
      login = "";
      password = "";
      server = "";
      domain = "";
    };
  };
}
