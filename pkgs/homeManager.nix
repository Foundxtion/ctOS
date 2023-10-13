{pkgs, config, ...}:
{
  home.stateVersion = "23.05";
  imports = [
    ./alacritty/hm-alacritty.nix
    ./discord/hm-discord.nix
    ./gnome/hm-gnome.nix
    ./i3/hm-i3.nix
    ./rofi/hm-rofi.nix
    ./vim/hm-vim.nix
    ./vscode/hm-vscode.nix
    ./zsh/hm-zsh.nix
  ];
}
