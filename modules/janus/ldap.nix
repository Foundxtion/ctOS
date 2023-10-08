{config, lib, pkgs, ...}:
let
    cfg = config.fndx.authentication.ldap;
in
with lib;
{
    options = {
        fndx.authentication.ldap = {
            enable = mkEnableOption "Janus LDAP configuration";

            server = mkOption {
                example = "ldaps://ldap.example.org"; 
                type = types.str;
                description = mdDoc "Janus LDAP server url";
            };

            dn = mkOption {
                example = "dc=example,dc=org"; 
                type = types.str;
                description = mdDoc "Janus LDAP base search dn";
            };
        }; 
    };

    config = mkIf cfg.enable {

        services.sssd = {
            enable = true;
            config = ''
                [sssd]
                config_file_version = 2
                services = nss, pam, ssh
                domains = LDAP

                [nss]
                override_shell = ${config.users.defaultUserShell}/bin/zsh

                [domain/LDAP]
                cache_credentials = true
                enumerate = false

                id_provider = ldap
                auth_provider = ldap

                ldap_uri = ${cfg.server}
                ldap_search_base = ${cfg.dn}
                ldap_user_search_base = ou=users,${cfg.dn}?subtree?(objectClass=posixAccount)
                ldap_group_search_base = ou=groups,${cfg.dn}?subtree?(objectclass=posixGroup)
                ldap_id_use_start_tls = true
                ldap_schema = rfc2307bis
                ldap_user_gecos = cn

                entry_cache_timeout = 600
                ldap_network_timeout = 2
            '';
        };

	environment.systemPackages = [
	    openldap
	];

        users.ldap = {
            enable = true;
            base = cfg.dn;
            server = cfg.server;
            nsswitch = false;
        };
    };
}
