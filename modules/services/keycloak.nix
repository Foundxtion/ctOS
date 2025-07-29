{config, lib, pkgs, ...}:
let
	cfg = config.fndx.services.keycloak;
in
with lib;
{
    options = {
        fndx.services.keycloak = {
            enable = mkEnableOption "Pre configured Keycloak for ctOS";
			netauth = {
				enable = mkEnableOption "Integration with netauth";
				realm = mkOption {
					example = "EXAMPLE.ORG";
					type = types.str;
					description = mdDoc ''
					The realm defined in netauth, 
					see fndx.services.netauth.realm for more information.
					'';
				};
			};
			hostname = mkOption {
					example = "auth.example.org";
					type = types.str;
					description = mdDoc ''
					The hostname where all requests will be pointed to
					for accessing the keycloak instance.
					'';
			};
			port = mkOption {
				default = 8080;
				description = mdDoc ''
					The port on which Keycloak runs.
				'';
			};
        };
    };

    config  = mkIf cfg.enable {
		environment.systemPackages = with pkgs; [
			keycloak
		];

		services.postgresql = {
			enable = true;
			enableTCPIP = true;
			ensureUsers = [
				{
					name = "root";
					ensureClauses.superuser = true;
				}
			];
		};

		fndx.authentication.krb5 = mkIf cfg.netauth.enable {
			enable = true;
			realm = cfg.netauth.realm;
		};

		services.keycloak = {
			enable = true;
			initialAdminPassword = "admincaca";
			package = let
				keycloakTheme = ./keycloak-theme.jar;
			in
				pkgs.keycloak.overrideAttrs( { preBuild ? "", ... }: {
				preBuild = preBuild + ''
					cp ${keycloakTheme} providers/keycloak-theme.jar;
				'';
			});
			database = {
				type = "postgresql";
				createLocally = true;
				username = "root";
				passwordFile = (pkgs.writeText "password" "passwordKeycloak").outPath;
			};
			settings = {
				hostname = "https://${cfg.hostname}";
				health-enabled = true;
				http-port = cfg.port;
				proxy-headers = "xforwarded";
				http-enabled = true;
			};
		};
		fndx.services.nginx = {
			enable = true;
			virtualHosts."${cfg.hostname}" = {
				enableACME = true;
				forceSSL = true;
				locations."/" = {
					extraConfig = ''
					proxy_set_header Host ${cfg.hostname};
					proxy_set_header X-Real-IP $remote_addr;
					proxy_set_header X-Forwarded-for $remote_addr;
					proxy_set_header X-Forwarded-Host   $host;
					proxy_set_header X-Forwarded-Server $host;
					proxy_set_header X-Forwarded-Port   $server_port;
					proxy_set_header X-Forwarded-Proto  $scheme;
					proxy_set_header Authorization $http_authorization;
					proxy_pass_header WWW-Authenticate;
					proxy_pass_header Authorization;
					'';
					proxyPass = "http://0.0.0.0:${toString cfg.port}/";
					proxyWebsockets = true;
				};
			};
		};
    };
}
