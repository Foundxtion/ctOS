{osConfig, lib, pkgs, ...}:
with lib;
{
    programs.zsh = mkIf osConfig.fndx.packages.zsh.enable {
        enable = true;
        shellAliases = {
            update="(cd /root/nixos && git pull && nixos-rebuild switch)";
        };
        zplug = {
          plugins = [
            { name = "zsh-users/zsh-autosuggestions"; }
          ];
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
