{config, pkgs, ...}:
{
    imports = [
        ./hardware
        ./home-manager
        ./networking
        ./nix
        ./services
    ];
}
