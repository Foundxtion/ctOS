{osConfig, lib, pkgs, ...}:
with lib;
{
    programs.zsh = mkIf osConfig.fndx.packages.zsh.enable {
        enable = true;
        enableAutosuggestions = true;
        enableCompletion = true;
        syntaxHighlighting.enable = true;
        autocd = true;
        shellAliases = {
            update="(cd /root/nixos && git pull && nixos-rebuild switch)";
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
