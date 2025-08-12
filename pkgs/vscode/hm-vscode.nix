{osConfig, lib, pkgs, ...}:
with lib;
{
    programs.vscode = mkIf osConfig.fndx.packages.vscode.enable {
        enable = true;
		profiles.default = {
			enableExtensionUpdateCheck = false;
			enableUpdateCheck = false;
			userSettings = {
				"window.titleBarStyle" = "custom";
				"[typescriptreact]" = {
					"editor.defaultFormatter" = "esbenp.prettier-vscode";
				};
				"[css]" = {
					"editor.defaultFormatter" = "esbenp.prettier-vscode";
				};
				"[json]" = {
					"editor.defaultFormatter" = "esbenp.prettier-vscode";
				};
				"editor.fontSize" = 13;
				"workbench.iconTheme" = "vscode-jetbrains-icon-theme-2023-auto";
				"editor.fontFamily" = "'JetBrains mono'";
				"[typescript]" = {
					"editor.defaultFormatter" = "esbenp.prettier-vscode";
				};
				"workbench.colorTheme" = "JetBrains Rider Dark Theme";
				"editor.formatOnSave"  = true;
				"terminal.integrated.defaultProfile.linux" = "shell";
				"terminal.integrated.profiles.linux" = {
					"shell" = {
						"path" = "nix-shell";
						"args" = [
							"--run"
							"zsh"
							"shell.nix"
						];
					};
					"zsh" = {
						"path" = "zsh";
					};
				};
			};
			extensions = with pkgs.vscode-extensions; [
				vscodevim.vim
				ms-dotnettools.csharp
				ms-dotnettools.csdevkit
				ms-dotnettools.vscode-dotnet-runtime
			] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
				{
					name = "jetbrains-rider-dark-theme";
					publisher = "EdwinSulaiman";
					version = "1.0.2";
					sha256 = "UkcP8fuIHE+mZ7bnVuux17gnd7XzLmBAnvPGeE1ptCs=";
				}

				{
					name = "vscode-jetbrains-icon-theme";
					publisher = "chadalen";
					version = "2.24.0";
					sha256 = "YdzJmZ9dfu71FDCYnrseX2ago+WGPU7f8kf6uZgI8rY=";
				}

				{
					name = "vscode-typescript-next";
					publisher = "ms-vscode";
					version = "5.8.20241225";
					sha256 = "1ojlDsWnpwvXMVEQeKN/RlNNVZh6pT3n/mKHD+hTqcI=";
				}
			];
		};
	};
}
