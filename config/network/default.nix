{pkgs, config, ...}:
let
  secrets = import ../secrets.nix;
  networkmanager.enable = true;
  hostname = secrets.hostName;
in
  {
    networking = if secrets.network.hasStaticAddress then {
      inherit networkmanager hostname;

      defaultGateway = secrets.network.defaultGateway;
      nameservers = [ "8.8.8.8" ];
      interfaces.eth0 = {
        ipAddress = secrets.network.ipAddress;
        prefixLength = secrets.network.prefixLength;
      };
    firewall = {
        allowedTCPPorts = [80 443 22];
        allowedUDPPorts = [80 443 22];
    };
  }
  else {
    inherit networkmanager hostname;
  };
}
