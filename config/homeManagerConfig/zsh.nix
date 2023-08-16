{ config, pkgs, ... } :
{
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.zsh = rec {
    enable = true;

	plugins = [
      {
        name = "powerlevel10k";
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
        src = pkgs.zsh-powerlevel10k;
      }
    ];

    initExtra = (builtins.readFile ./p10k.zsh);
  };
}
