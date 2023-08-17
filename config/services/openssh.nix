{config, pkgs, ...}:
let
  secrets = import ../secrets.nix;
in
{
  services.openssh = {
    enable = secrets.services.openssh.enable;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = secrets.services.openssh.permitRootLogin;
    };
  };
}
