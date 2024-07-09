{config, lib, pkgs, ...}:
let
    cfg = config.fndx.packages.firefox;
in
with lib;
{
    options.fndx.packages.firefox.enable = mkEnableOption "Firefox for ctOS";

    config = mkIf cfg.enable {
        programs.firefox = {
            enable = true;
            preferences = mkIf config.fndx.netauth.enable {
                "network.negotiate-auth.trusted-uris" = "${strings.toLower config.fndx.netauth.realm},.${strings.toLower config.fndx.netauth.realm}";
                "network.trr.excluded-domains" = "${strings.toLower config.fndx.netauth.realm}";
            };
            policies = {
                DisableTelemetry = true;
            };
        };
    };
}
