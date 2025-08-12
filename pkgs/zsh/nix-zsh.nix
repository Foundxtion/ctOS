{config, lib, pkgs, ...}:
with lib;
{
    options = {
        fndx.packages.zsh.enable = mkEnableOption "Zsh";  
    };

    config = mkIf config.fndx.packages.zsh.enable {
        programs.zsh.enable = true;
		programs.zoxide = {
			enable = true;
			enableZshIntegration = true;
		};
    };
}
