{osConfig, lib, pkgs, ...}:
with lib;
{
    programs.vscode = mkIf osConfig.fndx.packages.vscode.enable {
        enable = true;
    };
}
