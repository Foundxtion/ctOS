{
  description = "Foundation flake for auto configure a NixOS server";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follow = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager }: {

    nixosConfigurations = {
      foundation = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./config/configuration.nix
          home-manager.nixosModules.home-manager
        ];
      };
    };
  };
}
