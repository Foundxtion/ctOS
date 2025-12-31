{config, lib, pkgs, ...}:
let
    cfg = config.fndx.networking;
in
with lib;
{
    options = {
        fndx.networking = {
            useDHCP = mkOption {
                default = true;
                type = types.bool;
                description = mdDoc ''
                    Whether to attribute the local IPv4 address of your machine through DHCP.
                '';
            };
            ipv4Address = mkOption {
                default = "192.168.1.10";
                type = types.str;
                description = mdDoc ''
                    the static IPv4 address of your machine on the local network.
                    Use this when DHCP is turned off.
                '';
            };

            prefixLength = mkOption  {
                default = 24;
                type = types.int;
                description = mdDoc ''
                    The prefix length of the local network.
                    Use this when DHCP is turned off.
                '';
            };

            defaultGateway = mkOption {
                default = "192.168.1.1";
                type = types.str;
                description = mdDoc ''
                    The default gateway of the local network.
                    Use this when DHCP is turned off.
                '';
            };

            wakeOnLan.enable = mkEnableOption "Enable wake on lan through mac address";

            hostName = mkOption {
                default = "ctOS";
                type = types.str;
                description = mdDoc ''
                    The hostName of your machine on the local network.
                '';
            };

            extraAllowedPorts = mkOption {
                default = [];
                
                description = mdDoc ''
                    Additional TCP/UDP Ports to allow through firewall.
                '';
            };
        };
    };

    config = {
        networking = {
            useDHCP = mkForce cfg.useDHCP;
            wireless.enable = false;
            hostName = cfg.hostName;

            networkmanager.enable = true;

            firewall = let allowedPorts = optionals (config.fndx.services.nginx.enable) [ 
              80 443
            ] ++ optionals (config.fndx.services.openssh.enable) [
              22
            ] ++ optionals (config.fndx.services.mailserver.enable) [
              25 993 995 
            ] ++ optionals (config.fndx.services.netauth.enable) [
              749 464 88 389 636
            ] ++ optionals (config.fndx.services.k3s.enable) [
				6443 # k3s: required so that pods can reach the API server (running on port 6443 by default)
				8472 # k3s, flannel: required if using multi-node for inter-node networking
			] ++ cfg.extraAllowedPorts;
            in
            {
                enable = true;
                allowedTCPPorts = allowedPorts;
                allowedUDPPorts = allowedPorts;
            };
	    interfaces =  {
	    	eth0.ipv4.addresses = mkIf (!cfg.useDHCP) [{
                    address = cfg.ipv4Address;
                    prefixLength = cfg.prefixLength;
		}];
                eth0.wakeOnLan.enable = cfg.wakeOnLan.enable;
	    };

            defaultGateway = mkIf (! cfg.useDHCP) cfg.defaultGateway;
	    nameservers = if cfg.useDHCP then [cfg.defaultGateway] else [ "8.8.8.8" ];
        };
    };
}
