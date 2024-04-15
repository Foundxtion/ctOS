{config, pkgs, ...}:
{
  imports = [
    ./alacritty/nix-alacritty.nix
    ./cppkit/nix-cppkit.nix
    ./csharpkit/nix-csharpkit.nix
    ./discord/nix-discord.nix
    ./firefox/nix-firefox.nix
    ./gnome/nix-gnome.nix
    ./gtk/nix-gtk.nix
    ./i3/nix-i3.nix
    ./javakit/nix-javakit.nix
    ./nautilus/nix-nautilus.nix
    ./picom/nix-picom.nix
    ./plasma/nix-plasma.nix
    ./rofi/nix-rofi.nix
    ./rustkit/nix-rustkit.nix
    ./vim/nix-vim.nix
    ./vscode/nix-vscode.nix
    ./webkit/nix-webkit.nix
    ./zsh/nix-zsh.nix
  ];
}
