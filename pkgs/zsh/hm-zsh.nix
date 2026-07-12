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
			dpsa="docker ps -a --format 'table {{.Image}}\t{{.Command}}\t{{.RunningFor}}\t{{.Status}}'";
			ls="${pkgs.eza}/bin/eza";
			l="${pkgs.eza}/bin/eza -lah";
			ll="${pkgs.eza}/bin/eza -l";
        };

		initContent = let
            additionalScript = ''
            cd()
            {
                if [ -n "''\$1" ]; then
					z "''$@" && eza 
                else
					z && eza
                fi
            }
            '';
        in
        builtins.concatStringsSep "\n" [
            additionalScript
        ];
    };
	programs.starship = {
		enable = true;
		enableZshIntegration = true;
		settings = fromTOML (builtins.unsafeDiscardStringContext (builtins.readFile "${./gruvbox-rainbow.toml}"));
	};
}
