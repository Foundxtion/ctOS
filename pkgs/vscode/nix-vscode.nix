{config, lib, pkgs, ...}:
with lib;
{
    options = {
		fndx.packages.vscode = 
		{
			enable = mkEnableOption "Code for ctOS";
			copilot.enable = mkEnableOption "Copilot in Visual Studio code";
		};
    };
}
