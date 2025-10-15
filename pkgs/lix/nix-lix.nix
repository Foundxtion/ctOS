{config, lib, pkgs, ...}:
with lib;
{
    options = {
        fndx.packages.lix.enable = mkEnableOption "Replacement of nix by lix for faster package manager";  
    };

    config = mkIf config.fndx.packages.lix.enable {
		nixpkgs.overlays = [ (final: prev: {
			inherit (prev.lixPackagesSets.stable)
			nixpkgs-review
			nix-eval-jobs
			nix-fast-build
			colmena;
		}) ];

		nix.package = pkgs.lixPackageSets.stable.lix;
    };
}
