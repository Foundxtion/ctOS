{config, lib, pkgs, ...}:
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

            hostName = mkOption {
                default = "Foundxtion";
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
            wireless.enable = false;
            hostName = config.fndx.networking.hostName;
            networkmanager.enable = true;

            firewall = let allowedPorts = optionals (config.fndx.services.nginx.enable) [ 
                80 443
            ] ++ optionals (config.fndx.services.openssh.enable) [
                22
            ] ++ optionals (config.fndx.services.mailserver.enable) [
                25 993 995 
            ] ++ config.fndx.networking.extraAllowedPorts;
            in
            {
                allowedTCPPorts = allowedPorts;
                allowedUDPPorts = allowedPorts;
            };

            interfaces.eth0.ipv4.addresses = mkIf (! config.fndx.networking.useDHCP) [{
                address = config.fndx.networking.ipv4Address;
                prefixLength = config.fndx.networking.prefixLength;
            }];
            defaultGateway = mkIf (! config.fndx.networking.useDHCP) config.fndx.networking.defaultGateway;
        };
    };
}
