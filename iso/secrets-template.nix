{
  git-remote = "";
  hostName = "";
  username = "fndx";
  network = {
    hasStaticAddress = false;
    ipAddress = "";
    prefixLength = 0;
    defaultGateway = "";
  };
  authorizedKeys = [""];
  security.acme.email = "";
  services = {
    openssh = {
      permitRootLogin = "no"; # (yes/no)
    };
    ddclient = {
      password = "";
    };
  };
}
