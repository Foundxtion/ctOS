{config, lib, pkgs, ...}:
{
    imports = [
        ./ddclient.nix
        ./docker.nix
        ./mailserver.nix
        ./netauth.nix
        ./nginx.nix
        ./openssh.nix
    ];
}
