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
        allowedTCPPorts = [22 80 88 389 443 464 636 749];
        allowedUDPPorts = [22 80 88 389 443 464 636 749];
    };
  }
  else {
    inherit networkmanager hostName;
  };
}
