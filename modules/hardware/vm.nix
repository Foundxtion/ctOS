{config, lib, pkgs, ...}:
with lib;
{
    options.fndx.hardware.vbox.enable = mkEnableOption "virtual box support in case ctOS runs in a vm";

    config = mkIf config.fndx.hardware.vbox.enable {
		virtualisation.virtualbox.guest.enable = true;
    };
}
