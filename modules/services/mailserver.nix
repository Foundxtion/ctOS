{config, lib, pkgs, ...}:
with lib;
{
	imports = [
        # Importing nixos mailserver
	    (builtins.fetchTarball {
    		url = "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/archive/nixos-23.05/nixos-mailserver-nixos-23.05.tar.gz";
 			sha256 = "1ngil2shzkf61qxiqw11awyl81cr7ks2kv3r3k243zz7v2xakm5c";
	    })
	];
    options = {
        fndx.services.mailserver = {
            enable = mkEnableOption "Mailserver for Foundxtion.";
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
                    Definition of users of Foundxtion mailserver.
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
