{config, lib, pkgs, ...}:
let
    cfg = config.fndx.packages.nautilus;
in
with lib;
{
    options.fndx.packages.nautilus.enable = mkEnableOption "Nautilus for Foundxtion";

    config = mkIf cfg.enable {
        environment.systemPackages = with pkgs; [
            gnome3.nautilus
        ];

        services.gvfs.enable = mkIf config.fndx.packages.i3.enable true;
    };
}
