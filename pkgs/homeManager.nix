{pkgs, config, ...}:
{
  home.stateVersion = "23.05";
  imports = [
    ./zsh/hm-zsh.nix
  ];
}
