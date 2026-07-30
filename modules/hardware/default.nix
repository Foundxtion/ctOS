{config, pkgs, ...}:
{
  imports = [
      ./amd.nix
      ./bluetooth.nix
      ./nvidia.nix
      ./pipewire.nix
      ./pulseaudio.nix
      ./touchpad.nix
      ./vm.nix
  ];
}
