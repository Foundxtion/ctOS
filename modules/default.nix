{config, pkgs, ...}:
{
    imports = [
        ./graphical
        ./hardware
        ./home-manager
        ./netauth
        ./networking
        ./nix
        ./services
    ];
}
