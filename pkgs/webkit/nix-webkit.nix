{config, lib, pkgs, ...}:
let
  cfg = config.fndx.packages.webkit;
in
with lib;
{
    options = {
        fndx.packages.webkit.enable = mkEnableOption "Web development kit for ctOS";
    };

    config = mkIf cfg.enable {
        environment.systemPackages = with pkgs; [
            nodejs
        ];
    };
}
