{config, lib, pkgs, ...}:
let
  cfg = config.fndx.services.k3s;
in
with lib;
{
    options = {
        fndx.services.k3s = {
            enable = mkEnableOption "k3s for ctOS";
            token = mkOption {
                example = ["super private token"];
                type = types.str;
				description = mdDoc ''
					The token used for authentication.
					You can generate this token with the following command:
					```sh
					pwgen -s -n 16 | head -n1
					```
				'';
            };
			headNode = mkEnableOption "head node of the cluster";
			headAddress = mkOption {
                example = ["http://head-node:6443"];
				default = "";
                type = types.str;
				description = mdDoc ''
					Set the address towards the head-node of the cluster.
					Warning: Set this attribute only for nodes that are not the head-node. 
				'';
			};
        };
    };

    config = mkIf cfg.enable {
		assertions = [ 
			{
				assertion = (cfg.headNode == (cfg.headAddress == "") );
				message = "The headNode and headAddress attributes have been set together.";
			}
		];

        services.k3s = {
            enable = true;
			role = "server";
			token = cfg.token;
			clusterInit = cfg.headNode;
			serverAddr = mkIf (!cfg.headNode) cfg.headAddress;
			extraFlags = [ 
				"--write-kubeconfig-mode \"0644\""
				"--disable servicelb"
				"--disable traefik"
				"--disable localstorage"
			];
        };
    };
}
