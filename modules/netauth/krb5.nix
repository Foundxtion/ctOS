{config, lib, pkgs, ...}:
let
    cfg = config.fndx.authentication.krb5;
in
with lib;
{
    options = {
        fndx.authentication.krb5 = {
            enable = mkEnableOption "NetAuth Krb5 configuration";
            realm = mkOption {
                example = "EXAMPLE.ORG";
                type = types.str;
                description = mdDoc "The address that acts as kdc admin_server and realm name";
            };
        };
    };


    config = mkIf cfg.enable {
        environment.systemPackages = with pkgs; [
            krb5
            gsasl
        ];

        krb5 = {
            enable = true;
            libdefaults = {
                default_realm = strings.toUpper cfg.realm; 
                dns_fallback = true;
                dns_canonicalize_hostname = false;
                rdns = false;
                forwardable = true;
            };
            realms = {
                "${toUpper cfg.realm}" = {
                    kdc = strings.toLower cfg.realm;
                    admin_server = strings.toLower cfg.realm;
                };
            };
        };
    };
}
