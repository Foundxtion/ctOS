{config, lib, pkgs, ...}:
let
  cfg = config.fndx.services.vpn-client;
in
with lib;
{
    options = {
        fndx.services.vpn-client = {
            enable = mkEnableOption "VPN Client Service";
            serverAddress = mkOption {
                type = types.str;
                example = "vpn.example.com";
                description = "The address of the VPN server";
            };
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
        };
    };

    config = mkIf cfg.enable {
        services.openvpn.servers = {
            client = {
                config = ''
                    client
                    dev tun
                    proto udp
                    fast-io

					; compress
                    cipher aes-128-cbc
                    sndbuf 512000
                    rcvbuf 512000
                    mssfix 1460
                    txqueuelen 2000

                    remote ${cfg.serverAddress} ${toString cfg.port}
                    resolv-retry infinite
                    nobind
                    persist-tun

                    ca ${toString cfg.caPath}
                    cert ${toString cfg.certPath}
                    key ${toString cfg.keyPath}
                    verb 3
                '';
                updateResolvConf = true;
            };
        };

        # this is a hack to make sure the openvpn-client service is not started by default
        # You can start it manually with `systemctl start openvpn-client.service`
        systemd.services."openvpn-client".wantedBy = lib.mkForce [];
    };
}
