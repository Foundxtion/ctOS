{config, lib, pkgs, ...}:
{
    imports = [
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
