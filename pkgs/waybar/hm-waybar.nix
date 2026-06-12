{osConfig, lib, pkgs, ...}:
with lib;
{
	programs.waybar = mkIf osConfig.fndx.packages.waybar.enable {
      enable = true;
      systemd.enable = false;

      settings = {
        mainBar = {
          layer = "top";
          position = "top";

          modules-left = [ "custom/nixos" "hyprland/workspaces" ];
          modules-center = [ ];
          modules-right = [ "tray" "privacy" "bluetooth" "upower" "pulseaudio" "network" "clock" ];

      # --- Modules ---
      "custom/launcher" = {
        format = "";
        on-click = "${pkgs.swaysettings}/bin/swaysettings -p about";
        tooltip = false;
      };

      "hyprland/workspaces" = {
		  sort-by-number             = true;
		  disable-scroll-wrap-around = true;
		  disable-scroll             = false;
		  all-outputs                = false;
		  enable-bar-scroll          = true;
		  format                     = "{name}";
      };

	  "tray" = {
		  reverse-direction = true;
		  icon-size         = 24;
		  spacing           = 10;
	  };

	  "clock" = {
		  format         = "{:%b %d %H:%M}";
		  tooltip-format = "<tt><small>{calendar}</small></tt>";
	  };

	  "privacy" = {
		  icon-spacing = 2;
		  icon-size    = 16;
		  modules      = [
			  {
				  type = "screenshare";
			  }
			  {
				  type = "audio-out";
			  }
			  {
				  type = "audio-in";
			  }
		  ];
	  };

	  "bluetooth" = {
		  format                   = "󰂲";
		  format-off               = "󰂲";
		  format-on                = "󰂯";
		  format-connected         = "󰂱";
		  format-connected-battery = "󰂱";
		  on-click                 = "~/.config/test/drop-bluetooth.sh";
		  on-click-right           = "~/.config/test/drop-bluetooth.sh";
	  };

	  "network" = {
		  interval            = 30;
		  format-ethernet     = "󰈀 ";
		  format-wifi         = " ";
		  format-disconnected = " ";
		  format-disabled     = "󰀝";
		  on-click            = "XDG_CURRENT_DESKTOP=gnome gnome-control-center network";
		  tooltip-format      = "{essid} {ipaddr}";
	  };

	  "pulseaudio" = {
		  format         = "{icon} {volume}%";
		  format-muted   = "  {volume}%";
		  format-icons   = {
			  default    = [" " " " " "];
		  };
		  on-scroll-up   = "pactl set-sink-volume @DEFAULT_SINK@ +1%";
		  on-scroll-down = "pactl set-sink-volume @DEFAULT_SINK@ -1%";
		  on-click       = "~/.config/test/drop-audio.sh";
		  on-click-right = "~/.config/test/drop-audio.sh";
	  };
    };
  };

  # Part 3: CSS Styling (Slim & Aesthetic)
  style = ''
  @define-color bg-hover rgba(48, 123, 246, 1);
@define-color text-color white;
@define-color text-color-disabled rgba(255, 255, 255, 0.4);
@define-color accent-color rgb(0, 128, 255);

* {
  border: none;
  border-radius: 0;
  /*font-family: "Inter Mono", "JetBrainsMono Nerd Font";*/
  /*font-size: 17px;*/
  font-weight: normal;
  min-height: 0;
}

label {
  text-shadow: 0 4px 6px rgba(0, 0, 0, 0.56);
}

tooltip {
  border-radius: 18px;
}

image {
  -gtk-icon-style: symbolic;
  -gtk-icon-shadow: 0 4px 6px rgba(0, 0, 0, 0.56);
}

window#waybar {
  /* background: white; */
  color: @text-color;
  transition-duration: 0.25s;
}

window#waybar.hidden {
  opacity: 0.2;
}

window {
  background: transparent;
  border-radius: 0;
}

window > box {
  background: rgba(50, 50, 50, 0.35);
  background-clip: border-box;
}

/* All module containers */
window > box > box {
  padding: 0 8px;
}

/* All modules */
window > box > box > widget > * {
  padding: 4 8px;
}

window > box > box > widget > button:hover {
  background: @bg-hover;
}

.modules-left {
  border-top-left-radius: 0;
  border-bottom-left-radius: 0;
}

.modules-right {
  border-top-right-radius: 0;
  border-bottom-right-radius: 0;
}

window > box > box > widget button:insensitive {
  color: @text-color;
  font-weight: bold;
}

#workspaces button {
  /* padding: 0 10px; */
  background-color: transparent;
  /* Use box-shadow instead of border so the text isn't offset */
  box-shadow: inset 0 -3px transparent;
  color: @text-color;
}

/* https://github.com/Alexays/Waybar/wiki/FAQ#the-workspace-buttons-have-a-strange-hover-effect */
#workspaces button.visible,
#workspaces button:hover {
  box-shadow: inset 0 -2px #555555;
}

#workspaces button:hover {
  background: @bg-hover;
}

#workspaces button.focused {
  box-shadow: inset 0 -2px @accent-color;
}

#workspaces button.urgent {
  color: #bd2c40;
  box-shadow: inset 0 -2px #bd2c40;
}

#gamemode {
  color: @text-color-disabled;
}
#gamemode.running {
  color: @text-color;
}

#backlight {
  background-color: #90b1b1;
}

#custom-airplane {
  font-size: 24px;
}

#pulseaudio {
  font-family: "Inter Mono", "JetBrainsMono Nerd Font";
  font-size: 17px;
}

#bluetooth {
  font-size: 22px;
}

#bluetooth.disabled,
#bluetooth.off {
  color: @text-color-disabled;
}

#clock {
	font-family: "Inter";
}

#network {
  font-size: 18px;
}

#network.disconnected,
#network.disabled,
#network.linked {
  color: @text-color-disabled;
}

#pulseaudio.muted {
  color: @text-color-disabled;
}

#privacy {
}
#privacy-item {
  margin: 2px 0;
  padding: 0 16px;
  color: @text-color;
  border-radius: 100px;
  border: 1px solid rgba(255, 255, 255, 0.15);
}
#privacy-item.screenshare {
  background: #30c658;
}
#privacy-item.audio-in {
  background: #ffa915;
}
#privacy-item.audio-out {
  background: #1c71d8;
}

#tray menu {
	font-size: 10px;
	font-family: "Inter";
	font-weight: normal;
    background-color: rgba(30, 30, 30, 0.33);
    
    /* FIX 1: Add 'solid' and combine into one line */
    border: 1px solid rgba(255, 255, 255, 0.1);
    
    /* FIX 2: Ensure margins allow the border to be drawn inside the allocated space */
    margin: 5px; 
    
    padding: 8px;
    border-radius: 10px;
	box-shadow: none;
	margin: 0px;
	-gtk-icon-shadow: none;
}

#tray menu decoration {
    box-shadow: none;
}

#tray menu menuitem {
    background-color: transparent;
    color: rgba(221, 221, 221, 1);
    border-radius: 5px; 
    padding: 5px 10px;
    margin: 2px 0px; /* Adds spacing between items so they don't touch */
}

#tray menu menuitem:hover {
    background-color: rgba(48, 123, 246, 1);
    color: #ffffff;
    border-radius: 5px; /* Keeping this 5px looks smoother than snapping to 0px */
}
    '';
  };
}
