{config, pkgs, ...}:
{
    imports = [
        ./graphical
        ./hardware
        ./home-manager
        ./janus
        ./networking
        ./nix
        ./services
    ];
}
