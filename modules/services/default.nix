{config, lib, pkgs, ...}:
{
    imports = [
        ./ddclient.nix
        ./docker.nix
        ./mailserver.nix
        ./nginx.nix
        ./openssh.nix
    ];
}
