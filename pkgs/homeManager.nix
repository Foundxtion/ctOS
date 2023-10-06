{pkgs, config, ...}:
{
  home.stateVersion = "23.05";
  imports = [
    ./vscode/hm-vscode.nix
    ./discord/hm-discord.nix
    ./alacritty/hm-alacritty.nix
    ./zsh/hm-zsh.nix
    ./i3/hm-i3.nix
    ./gnome/hm-gnome.nix
    ./rofi/hm-rofi.nix
  ];
}
