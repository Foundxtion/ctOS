{config, lib, pkgs, ...}:
let
	cfg = config.fndx.services.mailserver;
in
with lib;
{
	imports = [
        # Importing nixos mailserver
	    (builtins.fetchTarball {
                url = "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/archive/nixos-25.11/nixos-mailserver-nixos-25.11.tar.gz";
                sha256 = "0pqc7bay9v360x2b7irqaz4ly63gp4z859cgg5c04imknv0pwjqw";
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
            loginAccounts = mkOption {
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
				default = 1;
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
	    	loginAccounts = cfg.loginAccounts;
	    	certificateScheme = "acme-nginx";
			stateVersion = cfg.stateVersion;
	    };
    };
}
