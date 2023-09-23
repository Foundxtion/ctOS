{config, pkgs, ...}:
{
  imports = [
      ./boot.nix
      ./users.nix
      ./location.nix
  ];
}
