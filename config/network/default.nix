{pkgs, config, ...}:
let
  secrets = import ../secrets;
in
{
  networking = {
    networkmanager.enable = true;
    hostName = secrets.hostName;
  };
}
