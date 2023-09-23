{config, pkgs, ...}:
{
    imports = [
        ./graphical
        ./hardware
        ./home-manager
        ./networking
        ./nix
        ./services
    ];
}
