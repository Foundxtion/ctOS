{config, lib, pkgs, ...}:
let
  cfg = config.fndx.packages.javakit;
in
with lib;
{
    options = {
        fndx.packages.javakit.enable = mkEnableOption "Java development kit for Foundxtion";
    };

    config = mkIf cfg.enable {
        environment.systemPackages = with pkgs; [
            jetbrains.idea-ultimate
            openjdk17
            openjdk11
        ];
    };
}
