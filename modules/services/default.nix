{config, lib, pkgs, ...}:
{
    imports = [
		./keycloak.nix
		./portainer.nix
        ./ddclient.nix
        ./docker.nix
        ./jupyterhub.nix
        ./mailserver.nix
        ./netauth.nix
        ./nginx.nix
        ./openssh.nix
        ./vpn-client.nix
        ./vpn-server.nix
    ];
}
