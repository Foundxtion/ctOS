{ config, pkgs, ... } :
{
  programs = {
    neovim = {
      enable = true;
      defaultEditor = true;
      vimAlias = true;
    };
    zsh.enable = true;
  };
}
