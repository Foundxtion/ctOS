{config, lib, pkgs, ...}:
let
    cfg = config.fndx.authentication.ldap;
in
with lib;
{
    options = {
        fndx.authentication.ldap = {
            enable = mkEnableOption "NetAuth LDAP configuration";

            server = mkOption {
                example = "ldaps://ldap.example.org"; 
                type = types.str;
                description = mdDoc "NetAuth LDAP server url";
            };
            dn = mkOption {
                example = "dc=example,dc=org"; 
                type = types.str;
                description = mdDoc "NetAuth LDAP base search dn";
            };
        }; 
    };

    config = mkIf cfg.enable {
	environment.systemPackages = with pkgs; [
	    openldap
	];

        users.ldap = {
            enable = true;
            base = cfg.dn;
            server = cfg.server;
            nsswitch = false;
            extraConfig = ''
SASL_MECH GSSAPI
SASL_REALM ${config.fndx.netauth.realm}
SASL_NOCANON on
'';
        };
    };
}
