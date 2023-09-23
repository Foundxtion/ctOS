{config, lib, pkgs, ...}:
let
    cfg = config.fndx.dev;
in
with lib;
{
    options = {
        fndx.dev.enable = mkEnableOption "Foundxtion Dev Profile";
    };

    config = mkIf cfg.enable {
        fndx.graphical = {
            enable = true;
            type = "i3";
        };
    };
}
