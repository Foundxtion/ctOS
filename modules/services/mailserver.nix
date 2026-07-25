{config, lib, pkgs, ...}:
let
	cfg = config.fndx.services.mailserver;
in
with lib;
{
	imports = [
        # Importing nixos mailserver
	    (builtins.fetchTarball {
                url = "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/archive/nixos-26.05/nixos-mailserver-nixos-26.05.tar.gz";
                sha256 = "1i2d9v2is1sfacaxyxncagyxlppipqmw554f1gfvq5b164djws5q";
	    })
	];
    options = {
        fndx.services.mailserver = {
            enable = mkEnableOption "Mailserver for ctOS.";
            domain = mkOption {
                default = "";
                example = "example.org";
                type = types.str;

                description = mdDoc ''
                    Domain used for mailserver.
                '';
            };
            accounts = mkOption {
                default = {};
                example = {
                    "user@example.com" = {
                        hashedPassword = "{BCRYPT}x";
                    };
                };

                description = mdDoc ''
                    Definition of users of ctOS mailserver.
                '';
            };
			stateVersion = mkOption {
				default = 3;
				description = mdDoc ''
				Since 25.11, a new state has been created following a migration
				of Dovecot: https://nixos-mailserver.readthedocs.io/en/latest/migrations.html
				For existing setup, please follow this tutorial, otherwise you can use the default value.
				'';
			};
        };
    };

    config = mkIf cfg.enable {
	    mailserver = {
	    	enable = true;
	    	fqdn = cfg.domain;
	    	domains = [ cfg.domain ];
	    	accounts = cfg.accounts;
			x509.useACMEHost = cfg.domain;
			stateVersion = cfg.stateVersion;
	    };
    };
}
