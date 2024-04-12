{config, lib, pkgs, ...}:
let
  cfg = config.fndx.packages.rustkit;
in
with lib;
{
    options = {
        fndx.packages.rustkit.enable = mkEnableOption "Rust development kit for Foundxtion";
    };

    config = mkIf cfg.enable {
        environment.systemPackages = with pkgs; [
            jetbrains.clion
            cargo
            rustc
        ];
    };
}
