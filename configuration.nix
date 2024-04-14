{config, pkgs, ...}:
{
  imports = [
      ./lib
      ./modules
      ./pkgs
      ./profiles
      ./settings.nix
      ./hardware-configuration.nix
  ];

  system.stateVersion = "23.05";
}
