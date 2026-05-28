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
		environment.systemPackages = let 
			commit = pkgs.writeShellScriptBin "commit"  ''
				GUM="${pkgs.gum}/bin/gum"
				GIT="${pkgs.git}/bin/git"
				in_git_repo=''$(''$GIT rev-parse --git-dir 2> /dev/null 1> /dev/null; echo $?)

				if [ "$in_git_repo" = "128" ]; then
					''$GUM log -sl error "Working directory is not a git repository."
					exit 1;
				fi

				TYPE=''$(''$GUM choose "fix" "feat" "docs" "chore" "revert") || exit 1;

				# Pre-populate the input with the type(scope): so that the user may change it
				SUMMARY=''$(''$GUM input --value "''$TYPE: " --placeholder "Summary of this change") || exit 1;

				# Commit these changes if user confirms
				''$GUM confirm "Commit changes?" && ''$GIT commit -m "''$SUMMARY" -m "''$DESCRIPTION"
			'';
		in
			[ commit ];
	};
}
