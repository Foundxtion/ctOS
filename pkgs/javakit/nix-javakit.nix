{config, lib, pkgs, ...}:
let
  cfg = config.fndx.packages.javakit;
in
with lib;
{
    options = {
        fndx.packages.javakit.enable = mkEnableOption "Java development kit for ctOS";
    };

    config = mkIf cfg.enable {
        environment.systemPackages = with pkgs; [
            jetbrains.idea
            openjdk17
        ];
    };
}
