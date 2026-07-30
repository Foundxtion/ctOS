{config, lib, pkgs, ...}:
with lib;
{
    options.fndx.hardware.pipewire.enable = mkEnableOption "Pipewire for ctOS";

    config = mkIf config.fndx.hardware.pipewire.enable {
		security.rtkit.enable = true;
		services.pipewire = {
			enable = true;
			alsa.enable = true;
			alsa.support32Bit = true;
			pulse.enable = true;
            wireplumber.enable = true;
            extraConfig.pipewire = {
              "99-lowlatency" = {
                "context.properties" = {
                  "default.clock.rate" = 48000;
                  "default.clock.quantum" = 1024;
                  "default.clock.min-quantum" = 32;
                  "default.clock.max-quantum" = 2048;
                };
              };
            };
		};
        services.pipewire.wireplumber.extraConfig = {
          "10-bluetooth-codecs" = {
            "monitor.bluez.properties" = {
              "bluez5.codecs" = [ "ldac" "aptx" "aptx_hd" "aac" "sbc_xq" "sbc" ];
              "bluez5.enable-sbc-xq" = true;
              "bluez5.enable-msbc" = true; # Keeps mSBC available only when mic is needed
              "bluez5.enable-hw-volume" = true;
            };
          };
        };

		environment.systemPackages = with pkgs; [
			pavucontrol
			pamixer
		];
	};
}
