{osConfig, lib, pkgs, ...}:
with lib;
{
    services.polybar = mkIf osConfig.fndx.packages.polybar.enable {
        enable = true;
        package = pkgs.polybarFull;

        script = ''
            PATH=$PATH:${pkgs.i3}/bin polybar top &
        '';
        
        config = {
            "bar/top" = {
                width             = "100%";
                height            = if (osConfig.fndx.graphical.hidpi)
                then "50px"
                else "25px";
                radius            = 0;
                modules-left      = "icon windows";
                modules-center = "tray";
                modules-right     = "network sound battery date";
                background        = "#A4202020";
                foreground        = "#e9e9e9";
                font-0            = if (osConfig.fndx.graphical.hidpi) 
                then "Inter:size=18;4" 
                else "Inter:size=9;4";
                font-1            = if (osConfig.fndx.graphical.hidpi)
                then "DejaVuSansM Nerd Font:size=25;5"
                else "DejaVuSansM Nerd Font:size=12;5";
                font-2            = if (osConfig.fndx.graphical.hidpi)
                then "DejaVuSansM Nerd Font:size=12;5"
                else "DejaVuSansM Nerd Font:size=10;5";
            };

            "module/tray" = {
                type = "internal/tray";
                tray-spacing = 10;
            };

            "module/windows" = {
                type             = "internal/xworkspaces";
                group-by-monitor = false;
                enable-click     = true;
                enable-scroll    = true;

                label-active            = "%name%";
                label-active-font       = 1;
                label-active-background = "#1B1B1B";
                label-active-underline  = "#1b1b1b";
                label-active-padding    = 1;

                label-occupied         = "%name%";
                label-occupied-font    = 1;
                label-occupied-padding = 1;

                label-urgent            = "%name%";
                label-urgent-font       = 1;
                label-urgent-background = "#C1292E";
                label-urgent-foreground = "#FDFFFC";
                label-urgent-padding    = 1;
            };

            "module/date" = {
                type          = "internal/date";
                internal      = 5;
                date          = "%a. %d %b.";
                time          = "%H:%M";
                label         = "%date% %time%";
                label-font    = 1;
                label-padding = 1;
            };

            "module/sound" = {
                type          = "internal/pulseaudio";
                use-ui-max    = false;
                format-volume = "<ramp-volume>";

                label-muted-font    = 2;
                label-muted         = "󰖁";
                label-muted-padding = 2;

                ramp-volume-font    = 2;
                ramp-volume-0       = "󰕿";
                ramp-volume-1       = "󰖀";
                ramp-volume-2       = "󰕾";
                ramp-volume-padding = 2;
                click-right         = "${pkgs.pavucontrol}/bin/pavucontrol";
            };

            "module/battery" = {
                type = "internal/battery";

                full-at = 99;

                low-at = 5;

                battery       = "BAT0";
                adapter       = "AC";
                poll-interval = 5;

                format-charging         = "<label-charging>% <animation-charging>";
                format-charging-font    = 3;
                format-charging-padding = 1;

                format-discharging         = "<label-discharging>% <ramp-capacity>";
                format-discharging-font    = 3;
                format-discharging-padding = 1;

                label-charging    = "%percentage%";
                label-discharging = "%percentage%";

                ramp-capacity-0 = "󰂎";
                ramp-capacity-1 = "󰁻";
                ramp-capacity-2 = "󰁽";
                ramp-capacity-3 = "󰁿";
                ramp-capacity-4 = "󰂁";
                ramp-capacity-5 = "󰁹";

                animation-charging-0 = "󰂆";
                animation-charging-1 = "󰂈";
                animation-charging-2 = "󰂉";
                animation-charging-3 = "󰂋";
                animation-charging-4 = "󰂅";

                animation-charging-framerate = 750;
            };

            "module/network" = {
                type           = "internal/network";
                interval       = "3.0";
                interface-type = "wireless";

                format-connected         = "<ramp-signal> <label-connected>";
                format-connected-font    = 3;
                format-disconnected      = "<label-disconnected>";
                format-disconnected-font = 3;

                format-packetloss      = "<label-packetloss>";
                format-packetloss-font = 3;

                label-connected    = "%essid% %downspeed:9%";
                label-disconnected = "󰤮";
                label-packetloss   = "󰤫";

                ramp-signal-0 = "󰤯";
                ramp-signal-1 = "󰤟";
                ramp-signal-2 = "󰤢";
                ramp-signal-3 = "󰤥";
                ramp-signal-4 = "󰤨";
            };

            "module/icon" = {
                type = "custom/text";

                label         = "";
                label-font    = 2;
                label-padding = 2;
            };
        };
    };
}
