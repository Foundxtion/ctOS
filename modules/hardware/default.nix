{config, pkgs, ...}:
{
  imports = [
      ./nvidia.nix
      ./amd.nix
  ];
}
