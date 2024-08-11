{osConfig, lib, pkgs, ...}:
with lib;
{
    home.sessionPath = mkIf osConfig.fndx.packages.csharpkit.enable [
        "$HOME/.dotnet/tools"
    ];
}
