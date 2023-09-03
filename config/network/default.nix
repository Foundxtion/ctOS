{pkgs, config, ...}:
let
  secrets = import ../secrets.nix;
  networkmanager.enable = true;
  hostName = secrets.hostName;
in
  {
    networking = if secrets.network.hasStaticAddress then {
      inherit networkmanager hostName;

      defaultGateway = secrets.network.defaultGateway;
      nameservers = [ "8.8.8.8" ];
      interfaces.eth0.ipv4.addresses = [{
        address = secrets.network.ipAddress;
        prefixLength = secrets.network.prefixLength;
      }];
    firewall = {
        allowedTCPPorts = [80 443 22 389 636 749];
        allowedUDPPorts = [80 443 22 389 636 749];
    };
  }
  else {
    inherit networkmanager hostName;
  };
}
