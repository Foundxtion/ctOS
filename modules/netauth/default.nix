{config, lib, pkgs, ...}:
let
    cfg = config.fndx.netauth;
    dnBuilder = with lib.strings; (server_name: concatMapStringsSep "," (x: "dc=" + x) (splitString "." (toLower server_name)));
    server = if (cfg.address == null) then "ldaps://${lib.strings.toLower cfg.realm}" else "ldaps://${lib.strings.toLower cfg.address}";
    dn = dnBuilder cfg.realm;
in
with lib;
{
    imports = [
        ./ldap.nix
        ./krb5.nix
    ];

    options = {
        fndx.netauth = {
            enable = mkEnableOption "NetAuth: Foundxtion network authentication client";
            realm = mkOption {
                example = "EXAMPLE.ORG";
                type = types.str;
                description = mdDoc "NetAuth realm";
            };
            address = mkOption {
                example = "EXAMPLE.ORG";
				default = null;
                type = types.nullOr types.str;
                description = mdDoc "NetAuth instance address";
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
        fndx.authentication.ldap = {
            enable = true;
            server = server;
            dn = dn;
        };
	fndx.authentication.krb5 = {
	    enable = true;
	    realm = cfg.realm;
		address = if (cfg.address != null) then cfg.address else (lib.strings.toLower cfg.realm);
        additionalDomainRealms = cfg.additionalDomainRealms;
	};
        security.pam.services = {
            systemd-user.makeHomeDir = true;
            sssd.makeHomeDir = true;
            login.text = ''
          # Authentication management.
          auth  [default=ignore success=1]  pam_succeed_if.so                                         quiet uid <= 1000
          auth  sufficient                  ${pkgs.pam_krb5}/lib/security/pam_krb5.so                 minimum_uid=1000
          auth  required                    pam_unix.so                                               try_first_pass nullok
          auth  optional                    pam_permit.so

          # Account management.
          account   sufficient  ${pkgs.pam_krb5}/lib/security/pam_krb5.so
          account   required    pam_unix.so
          account   optional    pam_permit.so

          # Password management.
          password  sufficient  ${pkgs.pam_krb5}/lib/security/pam_krb5.so
          password  required    pam_unix.so                           try_first_pass nullok sha512 shadow
          password  optional    pam_permit.so

          # Session management.
          session   [default=ignore success=3]  pam_succeed_if.so                                         uid <= 1000
          session   required                    ${pkgs.pam_krb5}/lib/security/pam_krb5.so
          session   optional                    ${pkgs.systemd}/lib/security/pam_systemd.so
          session   required                    pam_unix.so
          session   optional                    pam_permit.so
          session   required                    pam_loginuid.so
            '';
            i3lock.text = config.security.pam.services.login.text;
            sddm.text = config.security.pam.services.login.text;
            sshd.text = config.security.pam.services.login.text;
        };

        services.sssd = {
            enable = true;
            config = ''
[sssd]
    config_file_version = 2
    domains = ${lib.strings.toLower cfg.realm}
    services = nss, pam

[pam]
    offline_credentials_expiration = 7

[nss]
    override_shell = ${config.users.defaultUserShell}/bin/zsh

[domain/${lib.strings.toLower cfg.realm}]
    id_provider = ldap
    ldap_uri = ${server}
    ldap_search_base = ${dn}
    auth_provider = krb5
    krb5_server = ${lib.strings.toLower cfg.realm}
    krb5_kpasswd = ${lib.strings.toLower cfg.realm}
    krb5_realm = ${lib.strings.toUpper cfg.realm}
    entry_cache_timeout = 600
    ldap_network_timeout = 2
    cache_credentials = true
    account_cache_expiration = 7
            '';
        };
    };
}
