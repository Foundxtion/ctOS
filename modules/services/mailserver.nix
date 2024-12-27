{config, lib, pkgs, ...}:
with lib;
{
	imports = [
        # Importing nixos mailserver
	    (builtins.fetchTarball {
                url = "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/archive/nixos-24.11/nixos-mailserver-nixos-24.11.tar.gz";
                sha256 = "05k4nj2cqz1c5zgqa0c6b8sp3807ps385qca74fgs6cdc415y3qw";
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
        };
    };

    config = mkIf config.fndx.services.mailserver.enable {
	    mailserver = {
	    	enable = true;
	    	fqdn = config.fndx.services.mailserver.domain;
	    	domains = [ config.fndx.services.mailserver.domain ];
	    	loginAccounts = config.fndx.services.mailserver.loginAccounts;
	    	certificateScheme = "acme-nginx";
	    };
    };
}
