{config, lib, pkgs, ...}:
with lib;
{
	imports = [
        # Importing nixos mailserver
	    (builtins.fetchTarball {
                url = "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/archive/nixos-25.05/nixos-mailserver-nixos-25.05.tar.gz";
                sha256 = "1qn5fg0h62r82q7xw54ib9wcpflakix2db2mahbicx540562la1y";
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
