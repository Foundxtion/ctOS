{config, lib, pkgs, ...}:
with lib;
{
    options = {
        fndx.packages.vscode.enable = mkEnableOption "Code for ctOS";
    };
}
