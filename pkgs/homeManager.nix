{pkgs, config, ...}:
{
  imports = [
    ./alacritty/hm-alacritty.nix
    ./csharpkit/hm-csharpkit.nix
    ./discord/hm-discord.nix
    ./gtk/hm-gtk.nix
    ./i3/hm-i3.nix
    ./polybar/hm-polybar.nix
    ./rofi/hm-rofi.nix
    ./vim/hm-vim.nix
    ./vscode/hm-vscode.nix
    ./zsh/hm-zsh.nix
  ];
}
