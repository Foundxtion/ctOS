{config, pkgs, ...}:
{
  imports = [
    ./alacritty/nix-alacritty.nix
    ./nautilus/nix-nautilus.nix
    ./gnome/nix-gnome.nix
    ./i3/nix-i3.nix
    ./picom/nix-picom.nix
    ./rofi/nix-rofi.nix
    ./vim/nix-vim.nix
    ./zsh/nix-zsh.nix
  ];
}
