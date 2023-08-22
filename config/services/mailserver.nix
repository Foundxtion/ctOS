{config, pkgs, ...}:
let
  secrets = import ../secrets.nix;
  server = import ../machines/server.nix;
in
{
	imports = [
# Importing nixos mailserver
		(builtins.fetchTarball {
  			url = "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/archive/nixos-23.05/nixos-mailserver-nixos-23.05.tar.gz";
  			sha256 = "1ngil2shzkf61qxiqw11awyl81cr7ks2kv3r3k243zz7v2xakm5c";
		})
	];
	mailserver = {
		enable = true;
		fqdn = server.mailserver.fqdn;
		domains = server.mailserver.domains;
		loginAccounts = secrets.mailserver.loginAccounts;
		certificateScheme = "acme-nginx";
	};
}
