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
                description = mdDoc "The realm of your netauth instance";
            };
            address = mkOption {
                example = "example.org";
                type = types.str;
                description = mdDoc "The dns address towards your netauth instance";
            };
            additionalDomainRealms = mkOption {
                example = [ ".example.com" ".example.net" ];
                type = types.listOf types.str;
                default = [];
                description = mdDoc ''
                Additional domains to realm mappings. This is useful if you have
                multiple domains that should be mapped to the same realm.
                The format is .domain -> REALM.
                For example, if you have a realm EXAMPLE.ORG and you want to
                map both example.com and example.net to it,
                you would add .example.com and .example.net to this list.
                '';
              };
        };
    };


    config = mkIf cfg.enable {
        environment.systemPackages = with pkgs; [
            krb5
            gsasl
        ];

        security.krb5 = {
            enable = true;
            settings = {
                libdefaults = {
                    default_realm = strings.toUpper cfg.realm; 
                    dns_fallback = true;
                    dns_canonicalize_hostname = false;
                    rdns = false;
                    forwardable = true;
                };
                realms = {
                    "${toUpper cfg.realm}" = {
                        kdc = strings.toLower cfg.address;
                        admin_server = strings.toLower cfg.address;
                    };
                };
                domain_realm = {
                    "${strings.toLower cfg.address}" = "${strings.toUpper cfg.realm}";
                    ".${strings.toLower cfg.realm}" = "${strings.toUpper cfg.realm}";
                } ++ (lib.listToAttrs (map (domain: {
                    name = "${domain}";
                    value = "${strings.toUpper cfg.realm}";
                }) cfg.additionalDomainRealms));
            };
        };
    };
}
