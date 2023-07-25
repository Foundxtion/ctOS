{
  network = {
    ipAddress = "";
    prefixLength = 0;
    defaultGateway = "";
  };
  authorizedKey = "";
  services = {
    openssh = {
      permitRootLogin = false;
    };
    nginx = {
      virtualHosts = {
        # Here will be written all nginx virtualHosts config
      };
    };
  };
}
