{config, lib, pkgs, ...}:
let
  cfg = config.fndx.services.portainer;
in
with lib;
{
    options = {
        fndx.services.portainer = {
            enable = mkEnableOption "Portainer server for ctOS";
        };
    };

    config = mkIf cfg.enable {
        virtualisation.oci-containers.containers = {
            portainer = {
                autoStart = true;
                image = "portainer/portainer-ce:lts";
                ports = [ 
                    "8000:8000"
                    "9443:9443"
                ];

                volumes = [
					"/var/run/docker.sock:/var/run/docker.sock"
					"portainer_data:/data"
                    "/etc/localtime:/etc/localtime:ro"
                ];
            };
        };
    };
}
