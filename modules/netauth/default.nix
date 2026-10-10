{config, lib, pkgs, ...}:
let
    cfg = config.fndx.netauth;
    dnBuilder = with lib.strings; (server_name: concatMapStringsSep "," (x: "dc=" + x) (splitString "." (toLower server_name)));
    server = if (cfg.address == null) then "ldaps://${lib.strings.toLower cfg.realm}" else "ldaps://${lib.strings.toLower cfg.address}";
    dn = dnBuilder cfg.realm;
    kdc = lib.strings.toLower (if cfg.address == null then cfg.realm else cfg.address);
    # SSSD obtains and saves the TGT during pam_authenticate. Screen lockers do
    # not necessarily call pam_setcred or pam_open_session.
    passwordServices = [ "login" "sshd" "i3lock" "hyprlock" ];
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
        # Use one Kerberos PAM provider and keep the generated NixOS account,
        # password and session rules (including logind and environment setup).
        security.pam.krb5.enable = false;
        users.ldap.loginPam = false;
        security.krb5.settings.libdefaults.default_ccache_name = "KEYRING:persistent:%{uid}";
        security.pam.services = mkMerge [ (genAttrs passwordServices (name: {
            rules.auth.sss = {
                # A local account may also exist in LDAP. Try SSSD before
                # pam_unix can return success without acquiring a TGT.
                order = config.security.pam.services.${name}.rules.auth.unix.order - 10;
                settings = {
                    use_first_pass = mkForce false;
                    forward_pass = true;
                    ignore_unknown_user = true;
                };
            };
        })) {
            login.makeHomeDir = true;
            sshd.makeHomeDir = true;
            # SDDM includes the login stack supplied by NixOS.
        } ];

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
    krb5_server = ${kdc}
    krb5_kpasswd = ${kdc}
    krb5_realm = ${lib.strings.toUpper cfg.realm}
    krb5_ccname_template = KEYRING:persistent:%U
    entry_cache_timeout = 600
    ldap_network_timeout = 2
    cache_credentials = true
    account_cache_expiration = 7
            '';
        };
    };
}
