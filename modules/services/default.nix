{config, lib, pkgs, ...}:
{
    imports = [
        ./ddclient.nix
        ./docker.nix
        ./jupyterhub.nix
        ./keycloak.nix
        ./mailserver.nix
        ./netauth.nix
        ./nginx.nix
        ./openssh.nix
        ./portainer.nix
        ./vpn-client.nix
        ./vpn-server.nix
    ];
}
