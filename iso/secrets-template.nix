{
  git-remote = "https://github.com/Foundxtion/Foundxtion";
  hostName = "";
  username = "fndx";
  initialPasswordHash = "";
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
  mailserver.loginAccounts = {
    "user1@example.com" = {
      # Generate one with nix-shell -p mkpasswd --run 'mkpasswd -sm bcrypt'
      hashedPassword = "";
    };
  };
}
