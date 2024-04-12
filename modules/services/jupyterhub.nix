{config, pkgs, lib, ...}:
let
    cfg = config.fndx.services.jupyterhub;
    dnBuilder = with lib.strings; (server_name: concatMapStringsSep "," (x: "dc=" + x) (splitString "." (toLower server_name)));
in
with lib;
{
    options = {
        fndx.services.jupyterhub = {
            enable = mkEnableOption "Jupyterhub for Foundxtion";
            host = mkOption {
                default = "0.0.0.0";
                description = mdDoc ''
                    The host ip address to use.
                '';
            };
            port = mkOption {
                default = 6666;
                description = mdDoc ''
                    The host port to use.
                '';
            };
            ldapServerAddress = mkOption {
                example = "example.org";
                description = mdDoc ''
                    JupyterHub for Foundxtion uses an LDAP server 
                    as Identity manager.
                    Please provide a domain name linked to an LDAP server.
                '';
            };
        };
    };

    config = mkIf cfg.enable {
        systemd.services.jupyterhub = {
            path = with pkgs; [ iproute2 gawk ];
        };
        services.jupyterhub = {
            enable = true;
            host = cfg.host;
            port = cfg.port;

            # authentication is made through netauth
            authentication = "ldapauthenticator.LDAPAuthenticator";

            # Set up spawner configuration
            spawner = "dockerspawner.DockerSpawner";
            extraConfig = ''
            c.LDAPAuthenticator.server_address = "${cfg.ldapServerAddress}"
            c.LDAPAuthenticator.bind_dn_template = [
                "uid={username},ou=People,${dnBuilder cfg.ldapServerAddress}",
            ]
            c.LDAPAuthenticator.use_ssl = True

            import os
            stream = os.popen("ip addr show docker0 | grep 'inet ' | tr -s ' ' | awk '{$1=$1};1' | cut -d ' ' -f 2")
            output = stream.read()
            hub_ip = output.strip("\n").split("/")[0]
            print("hub_ip =", hub_ip)

            c.JupyterHub.hub_ip = hub_ip
            c.DockerSpawner.image_whitelist = {
                "Tensorflow": "quay.io/jupyter/tensorflow-notebook:cuda-latest",
                "Pytorch": "quay.io/jupyter/pytorch-notebook:cuda12-python-3.11.8",
            }
            c.DockerSpawner.image = "quay.io/jupyter/pytorch-notebook:cuda12-python-3.11.8"
            c.DockerSpawner.remove_containers = True
            c.DockerSpawner.extra_create_kwargs = {'user': 'root'}
            c.DockerSpawner.extra_host_config = {'runtime': 'nvidia'}
            c.Spawner.environment = {'GRANT_SUDO': 'yes'}

            # set up data persistence
            notebook_dir = os.environ.get("DOCKER_NOTEBOOK_DIR") or "/home/jovyan/work"
            c.DockerSpawner.notebook_dir = notebook_dir

            c.DockerSpawner.volumes = { "jupyterhub-user-{username}": notebook_dir }
            '';
            jupyterhubEnv = pkgs.python3.withPackages (p: with p; [
                jupyterhub
                dockerspawner
                jupyterhub-ldapauthenticator
            ]);
      };
  };
}
