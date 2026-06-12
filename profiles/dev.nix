{config, lib, pkgs, ...}:
let
    cfg = config.fndx.dev;
in
with lib;
{
    options = {
        fndx.dev.enable = mkEnableOption "ctOS Dev Profile";
        fndx.dev.cpp.enable = mkEnableOption "ctOS C/C++ development profile";
        fndx.dev.csharp.enable = mkEnableOption "ctOS C# development profile";
        fndx.dev.java.enable = mkEnableOption "ctOS Java development profile";
        fndx.dev.rust.enable = mkEnableOption "ctOS Rust development profile";
        fndx.dev.web.enable = mkEnableOption "ctOS Web development profile";
    };

    config = mkIf cfg.enable {
        fndx.graphical = {
            enable = true;
        };
        fndx.packages.vscode.enable = true;
        fndx.packages.discord.enable = true;

        fndx.packages.cppkit.enable = cfg.cpp.enable;
        fndx.packages.csharpkit.enable = cfg.csharp.enable;
        fndx.packages.javakit.enable = cfg.java.enable;
        fndx.packages.webkit.enable = cfg.web.enable;
        fndx.packages.rustkit.enable = cfg.rust.enable;
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
			ai-commit = pkgs.writeShellScriptBin "ai-commit" ''
				set -euo pipefail

				if ! git rev-parse --is-inside-work-tree &>/dev/null; then
				echo "Error: not inside a git repository." >&2
				exit 1
				fi


				DIFF=''$(git diff --cached)
				if [[ -z "''$DIFF" ]]; then
				DIFF=''$(git diff)
				fi

				if [[ -z "''$DIFF" ]]; then
				echo "Nothing to commit – working tree is clean." >&2
				exit 0
				fi


				PROMPT="You are an expert software engineer writing git commit messages.

				Rules (STRICT – never break them):
				1. Output ONLY the commit message, nothing else – no explanation, no markdown,
				no quotes, no trailing newline beyond the message itself.
				2. The first line MUST start with either \"fix: \" or \"feat: \" (lower-case).
				3. Every line MUST be at most 79 characters wide (hard limit).
				4. The subject line (first line) should be short and imperative.
				5. If extra context is useful, add a blank line then a body (also ≤79 cols).
				6. Do NOT include a period at the end of the subject line.

				Here is the diff to summarise:

				''${DIFF}"

				COMMIT_MSG=''$(echo "''$PROMPT" | llm)


				FIRST_LINE=''$(echo "''$COMMIT_MSG" | head -n1)

				if [[ ! "''$FIRST_LINE" =~ ^(fix|feat):\ .+ ]]; then
				echo "Warning: LLM output does not start with 'fix: ' or 'feat: '." >&2
				echo "Raw output:" >&2
				echo "''$COMMIT_MSG" >&2
				exit 1
				fi

				LONG_LINE=''$(echo "''$COMMIT_MSG" | awk 'length > 79 { print NR": "''$0 }')
				if [[ -n "''$LONG_LINE" ]]; then
				echo "Warning: one or more lines exceed 79 characters:" >&2
				echo "''$LONG_LINE" >&2
				fi


				echo ""
				echo "┌─ Commit message " "''$(printf '─%.0s' {1..60})"
				echo "''$COMMIT_MSG" | sed 's/^/│ /'
				echo "└''$(printf '─%.0s' {1..78})"
				echo ""


				echo "''$COMMIT_MSG" | wl-copy
				echo "✓ Commit message copied to clipboard."
			'';
		in
        [ 
          commit
          ai-commit 
          thunderbird
          obsidian
          libreoffice-qt
          gnome-text-editor
          gnome-calendar
          (llm.withPlugins {
            llm-deepseek = true;
            llm-cmd = true;
          })
        ];
      };
}
