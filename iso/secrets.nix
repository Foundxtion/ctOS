{
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
      permitRootLogin = false;
    };
    nginx = {
      enable = false;
      virtualHosts = {
        # Here will be written all nginx virtualHosts config
      };
    };
    ddclient = {
      enable = false;
      protocol = "";
      web = "";
      username = "";
      password = "";
      server = "";
      domain = "";
    };
  };
}
