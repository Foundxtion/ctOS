{config, lib, pkgs, ...}:
let
    cfg = config.fndx.janus;
    dnBuilder = with lib.strings; (server_name: concatMapStringsSep "," (x: "dc=" + x) (splitString "." (toLower server_name)));
in
with lib;
{
    imports = [
        ./ldap.nix
        ./krb5.nix
    ];

    options = {
        fndx.janus = {
            enable = mkEnableOption "Foundxtion network authentication";
            realm = mkOption {
                example = "EXAMPLE.ORG";
                type = types.str;
                description = mdDoc "Janus realm";
            };
        };
    };

    config = mkIf cfg.enable {
        fndx.authentication.ldap = {
            enable = true;
            server = "ldap://ldap.${lib.strings.toLower cfg.realm}";
            dn = dnBuilder cfg.realm;
        };
	fndx.authentication.krb5 = {
	    enable = true;
	    realm = cfg.realm;
	};
    };
}
