{pkgs, config, ...}:
{
  home.stateVersion = "26.05";

  imports = [
    ./alacritty/hm-alacritty.nix
    ./csharpkit/hm-csharpkit.nix
    ./discord/hm-discord.nix
    ./gtk/hm-gtk.nix
    ./hyprland/hm-hyprland.nix
    ./i3/hm-i3.nix
    ./polybar/hm-polybar.nix
    ./rofi/hm-rofi.nix
    ./vim/hm-vim.nix
    ./vscode/hm-vscode.nix
    ./waybar/hm-waybar.nix
    ./zsh/hm-zsh.nix
  ];
}
