{pkgs, config, ...}:
{
  home.stateVersion = "23.05";
  imports = [
    ./alacritty/hm-alacritty.nix
    ./zsh/hm-zsh.nix
    ./i3/hm-i3.nix
    ./rofi/hm-rofi.nix
  ];
}
