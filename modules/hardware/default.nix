{config, pkgs, ...}:
{
  imports = [
      ./amd.nix
      ./bluetooth.nix
      ./nvidia.nix
      ./pulseaudio.nix
  ];
}
