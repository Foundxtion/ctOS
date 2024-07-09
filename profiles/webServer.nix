{config, lib, pkgs, ...}:
let
  cfg = config.fndx.webServer;
  virtualHosts = config.fndx.services.nginx.virtualHosts;
in
with lib;
{
    options = {
        fndx.webServer = {
            enable = mkEnableOption "ctOS Webserver";
            domain = mkOption {
                example = "example.org";
                type = types.str;
                description = mdDoc ''
                    The domain name for your webserver. 
                '';
            };

            dynamicDns = {
                enable = mkEnableOption "Dynamic dns resolution"; 
                protocol = mkOption {
                    example = "namecheap";
                    type = types.str;
                    description = mdDoc ''
                        The protocol used by your DynDNS provider.
                    '';
                };
                password = mkOption {
                    type = types.str;
                    description = mdDoc ''
                        The password used for your DynDNS provider.
                    '';
                };
            };
            virtualHosts = mkOption {
                default = {
                    localhost = {};
                };
                type = types.attrs;
                description = mdDoc ''
                  Nginx declarative configuration.
                '';
            };
            acme-email = mkOption {
                default = "";
                example = "user@example.org";
                description = mdDoc ''
                    Email used for validation and renewal of ACME encryption certificates.
                '';
            };
        };
    };

    config = mkIf cfg.enable {
        fndx.services.ddclient = mkIf cfg.dynamicDns.enable {
            enable = true;
            domainName = cfg.domain;
            protocol = cfg.dynamicDns.protocol;
            password = cfg.dynamicDns.password;
        };

        fndx.services.nginx = {
            enable = true;
            virtualHosts = cfg.virtualHosts;
            acme-email = cfg.acme-email;
        };
    };
}
