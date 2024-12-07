{config, pkgs, lib, ...}:
let
    cfg = config.fndx.services.jupyterhub;
    dnBuilder = with lib.strings; (server_name: concatMapStringsSep "," (x: "dc=" + x) (splitString "." (toLower server_name)));
in
with lib;
{
    options = {
        fndx.services.jupyterhub = {
            enable = mkEnableOption "Jupyterhub for ctOS";
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
                    JupyterHub for ctOS uses an LDAP server 
                    as Identity manager.
                    Please provide a domain name linked to an LDAP server.
                '';
            };
            enableNvidiaSupport = mkEnableOption "Nvidia Runtime for Jupyterhub";
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
            c.DockerSpawner.allowed_images = {
                "Tensorflow": "quay.io/jupyter/tensorflow-notebook:cuda-latest",
                "Pytorch": "quay.io/jupyter/pytorch-notebook:cuda12-python-3.11.8",
                "Scipy with python3.10": "jupyter/scipy-notebook:python-3.10.10",
                "pyspark": "quay.io/jupyter/pyspark-notebook:python-3.12",
            }
            c.DockerSpawner.image = "quay.io/jupyter/pytorch-notebook:cuda12-python-3.11.8"
            c.DockerSpawner.remove = True
            c.DockerSpawner.extra_create_kwargs = {'user': 'root'}
            '' + (if cfg.enableNvidiaSupport then
            ''
            c.DockerSpawner.extra_host_config = {
                'device_requests': [
                    {
                        'Driver': 'cdi',
                        'DeviceIDs': ['nvidia.com/gpu=all']
                    }
                ],
                'security_opt': ['label=disable']
            }
            c.Spawner.environment = {'GRANT_SUDO': 'yes', 'NVIDIA_VISIBLE_DEVICES': 'all'}
            '' else
            ''
            c.Spawner.environment = {'GRANT_SUDO': 'yes'}
            '') +
            ''
            c.Spawner.mem_limit = "32G"

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
