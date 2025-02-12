{config, lib, pkgs, ...}:
{
    imports = [
        ./ddclient.nix
        ./vpn-client.nix
        ./docker.nix
        ./jupyterhub.nix
        ./mailserver.nix
        ./netauth.nix
        ./nginx.nix
        ./openssh.nix
    ];
}
