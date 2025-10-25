{config, lib, pkgs, ...}:
let
  cfg = config.fndx.services.rping;
in
with lib;
{
    options = {
        fndx.services.rping = {
			server = {
				enable = mkEnableOption "Rping server for ctOS";
				keytabPath = mkOption {
					type = types.path;
					description = mdDoc "The path to the keytab to use for server";
				};
				principal = mkOption {
					example = "HTTP/example.org@EXAMPLE.ORG";
					type = types.str;
					description = mdDoc "The principal to use from the keytab.";
				};
			};
			client = {
				enable = mkEnableOption "Rping client for ctOS";
				uri = mkOption {
					example = "https://example.org";
					type = types.str;
					description = mdDoc "The URI to contact an rping server.";
				};
				keytabPath = mkOption {
					type = types.path;
					description = mdDoc "The path to the keytab to use for server";
				};
				principal = mkOption {
					example = "HTTP/example.org@EXAMPLE.ORG";
					type = types.str;
					description = mdDoc "The principal to use from the keytab.";
				};
			};
        };
    };

	config = mkIf (cfg.server.enable || cfg.client.enable) (
		let
			exe = pkgs.callPackage ../../pkgs/rping {};
		in
		{
			environment.systemPackages = [ exe ];
			systemd.tmpfiles.rules = [ "d /var/lib/rping 0750 root root - -" ];


			systemd.services."rping-server" = mkIf cfg.server.enable {
				description = "A dynamic reverse DNS server for keeping tracks of multiple machines IPs."; 
				after = [ "network-online.target" ];
				requires = [ "network-online.target" ];
				wantedBy = [ "multi-user.target" ];


				path = [ exe ];

				environment = {
					KRB5_KTNAME = "${toString cfg.server.keytabPath}";
				};
				
				serviceConfig = { 
					Type = "simple";
					ExecStart = "${exe}/bin/rping serve --principal ${cfg.server.principal}";
					WorkingDirectory = "/var/lib/rping";
				};
			};

			systemd.services."rping-client" = mkIf cfg.client.enable (
				let
					realm = lib.elemAt (lib.splitString "@" cfg.client.principal) 1;
					client_exe = pkgs.writeShellScriptBin "execute-rping.sh" ''
						echo "Claiming TGT from principal" &&
						${pkgs.krb5}/bin/kinit -kt ${toString cfg.client.keytabPath} ${cfg.client.principal}
						echo "Executing rping send"
						${exe}/bin/rping send --url ${cfg.client.uri} --realm ${realm}
					'';
				in
				{
				description = "A trigger for the rping client to notify the IP of your machine to an rping server";
				after = [ "network-online.target" ];
				requires = [ "network-online.target" ];

				path = [ client_exe ];

				environment = {
					KRB5CCNAME = "/tmp/rping.cache";
				};

				serviceConfig = {
					Type = "oneshot";
					ExecStart = "${client_exe}/bin/execute-rping.sh";
				};
			});

			systemd.timers."rping-client" = mkIf cfg.client.enable {
				description = "Run rping-client.service every 5 minutes";
				wantedBy = [ "timers.target" ];
				timerConfig = {
					OnBootSec = "1m";
					OnUnitActiveSec = "5m";
				};
			};
		}
	);
}
