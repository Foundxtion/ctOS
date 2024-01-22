{config, lib, pkgs, ...}:
with lib;
{
    options = {
        fndx.services.nginx = {
            enable = mkEnableOption "Pre configured Nginx for Foundxtion";
            acme-email = mkOption {
                default = "";
                example = "user@example.org";
                description = mdDoc ''
                    Email used for validation and renewal of ACME encryption certificates.
                '';
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
        };
    };

    config  = mkIf config.fndx.services.nginx.enable {
        services.nginx = {
            enable = true;
            recommendedProxySettings = true;
            virtualHosts = config.fndx.services.nginx.virtualHosts;
        };

        security.acme = {
            acceptTerms = true;
            defaults.email = config.fndx.services.nginx.acme-email;
        };
    };
}
