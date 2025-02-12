{config, lib, pkgs, ...}:
with lib;
let
  cfg = config.fndx.services.vpn-server;
  route = types.submodule {
      options = {
          subnet = mkOption {
              type = types.str;
              example = "192.168.0.0";
              description = "The subnet to route";
          };
          netmask = mkOption {
              type = types.str;
              example = "255.255.255.0";
              description = "The netmask of the subnet";
          };
      };
  };
in
{
    options = {
        fndx.services.vpn-server = {
            enable = mkEnableOption "VPN Server Service";
            port = mkOption {
                type = types.int;
                default = 1194;
                description = "The port of the VPN server";
            };
            caPath = mkOption {
                type = types.path;
                example = "/etc/openvpn/ca.crt";
                description = "The path to the CA certificate";
            };
            certPath = mkOption {
                type = types.path;
                example = "/etc/openvpn/client.crt";
                description = "The path to the client certificate";
            };
            keyPath = mkOption {
                type = types.path;
                example = "/etc/openvpn/client.key";
                description = "The path to the client key";
            };
            dhPath = mkOption {
                type = types.path;
                example = "/etc/openvpn/dh.pem";
                description = "The path to the Diffie-Hellman parameters";
            };
            networkSubnet = mkOption {
                type = types.str;
                default = "10.8.0.0";
                description = "The network subnet for the VPN";
            };
            networkNetmask = mkOption {
                type = types.str;
                default = "255.255.255.0";
                description = "The network netmask for the VPN";
            };

            persistentIpPool = {
                enable = mkEnableOption "Enable persistent IP pool";
                filePath = mkOption {
                    type = types.path;
                    example = "/etc/openvpn/ipp.txt";
                    description = "The path to the file that stores the persistent IP pool";
                };
            };

            routes = mkOption {
                type = types.listOf route;
                default = [];
                description = "The routes to add to the VPN server";
            };

            dhcp-server = {
                enable = mkEnableOption "Enable Routing to dhcp server";
                address = mkOption {
                    type = types.str;
                    example = "10.8.0.1";
                };
            };
        };
    };

    config = mkIf cfg.enable {
        services.openvpn.servers = {
            server = {
                config = ''
                    port ${toString cfg.port}
                    proto udp
                    dev tun

                    ca ${toString cfg.caPath}
                    cert ${toString cfg.certPath}
                    key ${toString cfg.keyPath}

                    dh ${toString cfg.dhPath}

                    topology subnet
                    server ${cfg.networkSubnet} ${cfg.networkNetmask}
                    ${optionalString (cfg.persistentIpPool.enable) ''
                    ifconfig-pool-persist ${cfg.persistentIpPool.filePath}
                    ''}

                    keepalive 20 120

                    verb 1
                    explicit-exit-notify 1

                    push "tcp-nodelay 1"
                    ${optionalString (cfg.dhcp-server.enable) ''
                    push "dhcp-option DNS ${cfg.dhcp-server.address}"
                    ''}
                    '' ++ concatStringsSep "\n" (map (route: ''
                    push "route ${route.subnet} ${route.netmask}"
                    '') cfg.routes);
            };
        };
    };
}
