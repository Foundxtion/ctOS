{config, lib, pkgs, ...}:
let
    home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/release-25.11.tar.gz";
in
{
    imports = [
        (import "${home-manager}/nixos")
    ];

    home-manager = {
        useUserPackages = true;
        useGlobalPkgs = true;
    };
}
