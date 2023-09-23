{config, lib, pkgs, ...}:
with lib;
{
    options = {
        fndx.services.ddclient = {
            enable = mkEnableOption "Dynamic DNS resolution";

            getIpService = mkOption {
                default = "dynamicdns.park-your-domain.com/getip";
                type = types.str;
                description = mdDoc ''
                    A third party service url that provides your ip when curl to.
                '';
            };

            protocol = mkOption {
                example = "namecheap";
                type = types.str;
                description = mdDoc ''
                    The protocol used for dynamic dns resolution.
                '';
            };

            password = mkOption {
                type = types.str;
                description = mdDoc ''
                    The password used for dynamic dns resolution.
                '';
            };

            server = mkOption {
                default = "dynamicdns.park-your-domain.com";
                type = types.str;
                description = mdDoc ''
                    A third party service domain name that provides your ip when curl to.
                '';
            };

            domainName = mkOption {
                example = "example.org";
                type = types.str;
                description = mdDoc ''
                    The domain name you own and want to dynamically resolve.
                '';
            };
        };
    };

    config = mkIf config.fndx.services.ddclient.enable {
        services.ddclient = {
            enable = true;
            configFile = pkgs.writeText "ddclient-config-file" ''
                use=web, web=${config.fndx.services.ddclient.getIpService}
                protocol=${config.fndx.services.ddclient.protocol}
                server=${config.fndx.services.ddclient.server}
                login=${config.fndx.services.ddclient.domainName}
                password=${config.fndx.services.ddclient.password}
                @
            '';
        };
    };
}
