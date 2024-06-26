{osConfig, lib, pkgs, ...}:
with lib;
{
    programs.zsh = mkIf osConfig.fndx.packages.zsh.enable {
        enable = true;
        autosuggestion.enable = true;
        enableCompletion = true;
        syntaxHighlighting.enable = true;
        autocd = true;
        shellAliases = {
            update="(cd /etc/nixos && git pull && nixos-rebuild switch)";
            nxs="nix-shell --run zsh";
        };
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
