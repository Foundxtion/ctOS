{config, lib, pkgs, ...}:
let
    cfg = config.fndx.packages.firefox;
in
with lib;
{
    options.fndx.packages.firefox.enable = mkEnableOption "Firefox for Foundxtion";

    config = mkIf cfg.enable {
        environment.systemPackages = with pkgs; optionals (config.fndx.netauth.enable) [
            (wrapFirefox firefox-unwrapped {
                extraPrefs = ''
                    pref("network.negotiate-auth.trusted-uris", "${toLower config.fndx.netauth.realm},.${toLower config.fndx.netauth.realm}");
                    pref("network.trr.excluded-domains", "${toLower config.fndx.netauth.realm}");
                '';
            })
        ] ++ optionals (!config.fndx.netauth.enable) [
            firefox
        ];
    };
}
