{config, lib, pkgs, ...}:
let
  cfg = config.fndx.packages.csharpkit;
in
with lib;
{
    options = {
        fndx.packages.csharpkit.enable = mkEnableOption "C# development kit for ctOS";
        fndx.packages.csharpkit.dotnetPackage = mkOption {
            type = lib.types.package;
            default = pkgs.dotnet-sdk_8;
            description = "The dotnet package version to use";
        };
    };

    config = mkIf cfg.enable {
        environment.systemPackages = with pkgs; [
            cfg.dotnetPackage
            jetbrains.rider
        ];

        environment.variables = {
            DOTNET_ROOT = "${cfg.dotnetPackage}";
        };
    };
}
