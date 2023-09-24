{lib, osConfig, pkgs, ...}:
let
    mod = "Mod4";
    defaultTerminal = "${pkgs.alacritty}/bin/alacritty";
in
with lib;
{
    xsession.windowManager.i3 = mkIf osConfig.fndx.packages.i3.enable {
        enable = true;
        config = {
            fonts = {
                names = [ "DejaVu Sans Mono" ];
            };
            gaps = {
                inner = 10;
                outer = 0;
                smartBorders = "on";
                smartGaps = true;
            };
            window.border = 0;
            menu = "${pkgs.rofi}/bin/rofi -show drun";
            terminal = defaultTerminal;

            modifier = mod;
            floating.modifier = mod;

            workspaceAutoBackAndForth = true;

            keybindings = {
                "XF86AudioRaiseVolume" = "exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ +10%";
                "XF86AudioLowerVolume" = "exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ -10%";
                "XF86AudioMute" = "exec --no-startup-id pactl set-sink-mute @DEFAULT_SINK@ toggle";
                "XF86AudioMicMute" = "exec --no-startup-id pactl set-source-mute @DEFAULT_SOURCE@ toggle";
                "XF86MonBrightnessUp" = "exec --no-startup-id light -A 4";
                "XF86MonBrightnessDown" = "exec --no-startup-id light -U 5";
                "${mod}+l" = "exec i3lock-fancy-rapid 5 3";
                "${mod}+Return" = "exec alacritty";
                "${mod}+a" = "exec firefox";
                "${mod}+e" = "exec nautilus";
                "${mod}+q" = "kill";
                "${mod}+d" = "exec --no-startup-id rofi -show drun -show-icons";

                "Print" = "exec spectacle";

                "${mod}+Left" = "focus left";
                "${mod}+Down" = "focus down";
                "${mod}+Up" = "focus up";
                "${mod}+Right" = "focus right";

                "${mod}+Shift+Left" = "move left";
                "${mod}+Shift+Down" = "move down";
                "${mod}+Shift+Up" = "move up";
                "${mod}+Shift+Right" = "move right";

                "${mod}+h" = "split h";
                "${mod}+v" = "split v";

                "${mod}+f" = "fullscreen toggle";
                "${mod}+Shift+space" = "floating toggle";
                "${mod}+space" = "focus mode_toggle";

                "${mod}+1" = "workspace number 1";
                "${mod}+2" = "workspace number 2";
                "${mod}+3" = "workspace number 3";
                "${mod}+4" = "workspace number 4";
                "${mod}+5" = "workspace number 5";
                "${mod}+6" = "workspace number 6";
                "${mod}+7" = "workspace number 7";
                "${mod}+8" = "workspace number 8";
                "${mod}+9" = "workspace number 9";
                "${mod}+10" = "workspace number 10";

                "${mod}+Shift+1" = "move container workspace number 1";
                "${mod}+Shift+2" = "move container workspace number 2";
                "${mod}+Shift+3" = "move container workspace number 3";
                "${mod}+Shift+4" = "move container workspace number 4";
                "${mod}+Shift+5" = "move container workspace number 5";
                "${mod}+Shift+6" = "move container workspace number 6";
                "${mod}+Shift+7" = "move container workspace number 7";
                "${mod}+Shift+8" = "move container workspace number 8";
                "${mod}+Shift+9" = "move container workspace number 9";
                "${mod}+Shift+10" = "move container workspace number 10";
                "${mod}+Shift+c" = "reload";
                "${mod}+Shift+r" = "restart";

                "${mod}+r" = "mode \"resize\"";
            };

            modes.resize = {
                "h" = "resize shrink width 20 px or 20 ppt";
                "j" = "resize grow height 20 px or 20 ppt";
                "k" = "resize shrink height 20 px or 20 ppt";
                "l" = "resize grow width 20 px or 20 ppt";

                "Return" = "mode \"default\"";
                "Escape" = "mode \"default\"";
            };
        };
    };
}
