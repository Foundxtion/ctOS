{pkgs, config, ...}:
{
  home.stateVersion = "23.11";
  imports = [
    ./alacritty/hm-alacritty.nix
    ./discord/hm-discord.nix
    ./gnome/hm-gnome.nix
    ./gtk/hm-gtk.nix
    ./i3/hm-i3.nix
    ./rofi/hm-rofi.nix
    ./vim/hm-vim.nix
    ./vscode/hm-vscode.nix
    ./zsh/hm-zsh.nix
  ];
}
