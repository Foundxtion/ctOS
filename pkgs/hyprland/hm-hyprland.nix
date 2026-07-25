{ lib, osConfig, pkgs, ... }:
let
  defaultTerminal = "${pkgs.alacritty}/bin/alacritty -o font.size=13";
  sshConfig = osConfig.fndx.packages.hyprland.openSshTab;
  package = pkgs.hyprland;
  lua = lib.generators.mkLuaInline;
in
with lib;
{
  config = mkIf osConfig.fndx.packages.hyprland.enable {
    home.file.".wayland-session" = {
      source = "${package}/bin/start-hyprland";
      executable = true;
    };
    home.pointerCursor = {
      gtk.enable = true;
      x11.enable = true;
      package = pkgs.apple-cursor;
      name = "macOS";
      size = 16;
    };
    home.packages = with pkgs; [
      adwaita-fonts
      swaynotificationcenter
      nerd-fonts.jetbrains-mono
      font-awesome
      inter
      grim
      slurp
      wl-clipboard
      hyprlock
      brightnessctl
    ];

    services.hyprpaper = {
      enable = true;
      settings = {
        ipc = "on";
        splash = false;
        wallpaper = {
          monitor = "";
          path = "${osConfig.fndx.graphical.background}";
          fit_mode = "cover";
        };
      };
    };

    services.swayosd.enable = true;

    wayland.windowManager.hyprland = {
      enable = true;
      settings = {
        mod = { _var = "SUPER"; };
        terminal = { _var = defaultTerminal; };
        menu = { _var = "${pkgs.rofi}/bin/rofi -show drun -show-icons"; };

        monitor = {
          output = "";
          mode = "preferred";
          position = "auto";
          scale = 1;
        };

        layer_rule = [
          { match = { namespace = "waybar"; }; blur = true; }
          { match = { namespace = "rofi"; }; blur = true; }
          { match = { namespace = "swaync-control-center"; }; blur = true; ignore_alpha = 0.5; }
          { match = { namespace = "swaync-notification-window"; }; blur = true; ignore_alpha = 0.5; }
        ];

		config = {
			dwindle = {
				preserve_split = true;
			};
			general = {
				gaps_in = 10;
				gaps_out = 10;
				layout = "dwindle";
				col = {
					active_border = "rgba(33ccffee)";
					inactive_border = "rgba(595959aa)";
				};
				resize_on_border = false;
				allow_tearing = false;
			};

			decoration = {
				rounding = 5;
				blur = {
					enabled = true;
					size = 5;
					passes = 2;
					vibrancy = 10.0;
				};
				shadow = {
					enabled = false;
					range = 4;
					render_power = 3;
				};
			};
			misc = {
				disable_hyprland_logo = true;
				disable_splash_rendering = true;
			};

			input = {
				kb_layout = "us";
				follow_mouse = 1;
			};
		};

        curve = [
          { _args = [ "easeOutQuint"  { type = "bezier"; points = [ [0.23 1] [0.32 1] ]; } ]; }
          { _args = [ "easeInOutCubic" { type = "bezier"; points = [ [0.65 0.05] [0.36 1] ]; } ]; }
          { _args = [ "linear"         { type = "bezier"; points = [ [0 0] [1 1] ]; } ]; }
          { _args = [ "almostLinear"   { type = "bezier"; points = [ [0.5 0.5] [0.75 1.0] ]; } ]; }
          { _args = [ "quick"          { type = "bezier"; points = [ [0.15 0] [0.1 1] ]; } ]; }
        ];

        animation = [
          { leaf = "global";          enabled = true; speed = 10;   bezier = "default"; }
          { leaf = "border";          enabled = true; speed = 5.39; bezier = "easeOutQuint"; }
          { leaf = "windows";         enabled = true; speed = 4.79; bezier = "easeOutQuint"; }
          { leaf = "windowsIn";       enabled = true; speed = 4.1;  bezier = "easeOutQuint"; style = "popin 87%"; }
          { leaf = "windowsOut";      enabled = true; speed = 1.49; bezier = "linear";       style = "popin 87%"; }
          { leaf = "fadeIn";          enabled = true; speed = 1.73; bezier = "almostLinear"; }
          { leaf = "fadeOut";         enabled = true; speed = 1.46; bezier = "almostLinear"; }
          { leaf = "fade";            enabled = true; speed = 3.03; bezier = "quick"; }
          { leaf = "layers";          enabled = true; speed = 3.81; bezier = "easeOutQuint"; }
          { leaf = "layersIn";        enabled = true; speed = 4;    bezier = "easeOutQuint"; style = "fade"; }
          { leaf = "layersOut";       enabled = true; speed = 1.5;  bezier = "linear";       style = "fade"; }
          { leaf = "fadeLayersIn";    enabled = true; speed = 1.79; bezier = "almostLinear"; }
          { leaf = "fadeLayersOut";   enabled = true; speed = 1.39; bezier = "almostLinear"; }
          { leaf = "workspaces";      enabled = true; speed = 1.94; bezier = "almostLinear"; style = "fade"; }
          { leaf = "workspacesIn";    enabled = true; speed = 1.21; bezier = "almostLinear"; style = "fade"; }
          { leaf = "workspacesOut";   enabled = true; speed = 1.94; bezier = "almostLinear"; style = "fade"; }
        ];


        bind = [
          { _args = [ (lua "mod .. \" + Return\"")        (lua "hl.dsp.exec_cmd(terminal)") ]; }
          { _args = [ (lua "mod .. \" + CTRL + Return\"") (lua "hl.dsp.exec_cmd(terminal .. \" -e su\")") ]; }
          { _args = [ (lua "mod .. \" + a\"")             (lua ''hl.dsp.exec_cmd("firefox")'') ]; }
          { _args = [ (lua "mod .. \" + e\"")             (lua ''hl.dsp.exec_cmd("nautilus")'') ]; }
          { _args = [ (lua "mod .. \" + d\"")             (lua "hl.dsp.exec_cmd(menu)") ]; }
          { _args = [ (lua "mod .. \" + q\"")             (lua "hl.dsp.window.close()") ]; }
          { _args = [ (lua "mod .. \" + SHIFT + E\"")     (lua "hl.dsp.exit()") ]; }
          { _args = [ (lua "mod .. \" + f\"")             (lua "hl.dsp.window.fullscreen({})") ]; }
          { _args = [ (lua "mod .. \" + SHIFT + space\"") (lua "hl.dsp.window.float({})") ]; }
          { _args = [ (lua "mod .. \" + space\"")         (lua ''hl.dsp.exec_cmd("hyprctl dispatch centerwindow")'') ]; }
          { _args = [ (lua "mod .. \" + h\"")             (lua ''hl.dsp.layout("togglesplit")'') ]; }
          { _args = [ (lua "mod .. \" + left\"")          (lua "hl.dsp.focus({ direction = \"l\" })") ]; }
          { _args = [ (lua "mod .. \" + right\"")         (lua "hl.dsp.focus({ direction = \"r\" })") ]; }
          { _args = [ (lua "mod .. \" + up\"")            (lua "hl.dsp.focus({ direction = \"u\" })") ]; }
          { _args = [ (lua "mod .. \" + down\"")          (lua "hl.dsp.focus({ direction = \"d\" })") ]; }
          { _args = [ (lua "mod .. \" + SHIFT + left\"")  (lua "hl.dsp.window.move({ direction = \"l\" })") ]; }
          { _args = [ (lua "mod .. \" + SHIFT + right\"") (lua "hl.dsp.window.move({ direction = \"r\" })") ]; }
          { _args = [ (lua "mod .. \" + SHIFT + up\"")    (lua "hl.dsp.window.move({ direction = \"u\" })") ]; }
          { _args = [ (lua "mod .. \" + SHIFT + down\"")  (lua "hl.dsp.window.move({ direction = \"d\" })") ]; }
          { _args = [ (lua "mod .. \" + 1\"")             (lua "hl.dsp.focus({ workspace = 1 })") ]; }
          { _args = [ (lua "mod .. \" + 2\"")             (lua "hl.dsp.focus({ workspace = 2 })") ]; }
          { _args = [ (lua "mod .. \" + 3\"")             (lua "hl.dsp.focus({ workspace = 3 })") ]; }
          { _args = [ (lua "mod .. \" + 4\"")             (lua "hl.dsp.focus({ workspace = 4 })") ]; }
          { _args = [ (lua "mod .. \" + 5\"")             (lua "hl.dsp.focus({ workspace = 5 })") ]; }
          { _args = [ (lua "mod .. \" + 6\"")             (lua "hl.dsp.focus({ workspace = 6 })") ]; }
          { _args = [ (lua "mod .. \" + 7\"")             (lua "hl.dsp.focus({ workspace = 7 })") ]; }
          { _args = [ (lua "mod .. \" + 8\"")             (lua "hl.dsp.focus({ workspace = 8 })") ]; }
          { _args = [ (lua "mod .. \" + 9\"")             (lua "hl.dsp.focus({ workspace = 9 })") ]; }
          { _args = [ (lua "mod .. \" + 0\"")             (lua "hl.dsp.focus({ workspace = 10 })") ]; }
          { _args = [ (lua "mod .. \" + SHIFT + 1\"")     (lua "hl.dsp.window.move({ workspace = 1 })") ]; }
          { _args = [ (lua "mod .. \" + SHIFT + 2\"")     (lua "hl.dsp.window.move({ workspace = 2 })") ]; }
          { _args = [ (lua "mod .. \" + SHIFT + 3\"")     (lua "hl.dsp.window.move({ workspace = 3 })") ]; }
          { _args = [ (lua "mod .. \" + SHIFT + 4\"")     (lua "hl.dsp.window.move({ workspace = 4 })") ]; }
          { _args = [ (lua "mod .. \" + SHIFT + 5\"")     (lua "hl.dsp.window.move({ workspace = 5 })") ]; }
          { _args = [ (lua "mod .. \" + SHIFT + 6\"")     (lua "hl.dsp.window.move({ workspace = 6 })") ]; }
          { _args = [ (lua "mod .. \" + SHIFT + 7\"")     (lua "hl.dsp.window.move({ workspace = 7 })") ]; }
          { _args = [ (lua "mod .. \" + SHIFT + 8\"")     (lua "hl.dsp.window.move({ workspace = 8 })") ]; }
          { _args = [ (lua "mod .. \" + SHIFT + 9\"")     (lua "hl.dsp.window.move({ workspace = 9 })") ]; }
          { _args = [ (lua "mod .. \" + SHIFT + 0\"")     (lua "hl.dsp.window.move({ workspace = 10 })") ]; }
          { _args = [ (lua "\"Print\"")                   (lua ''hl.dsp.exec_cmd("grim - | tee /home/${osConfig.fndx.user.name}/Screenshots/$(date +'%s_grim.png') | wl-copy")'') ]; }
          { _args = [ (lua "mod .. \" + SHIFT + s\"")     (lua ''hl.dsp.exec_cmd("grim -g \"$(slurp)\" - | tee /home/${osConfig.fndx.user.name}/main.png | wl-copy")'') ]; }
          { _args = [ (lua "mod .. \" + l\"")             (lua ''hl.dsp.exec_cmd("hyprlock")'') ]; }
          { _args = [ (lua "mod .. \" + SHIFT + c\"")     (lua ''hl.dsp.exec_cmd("hyprctl reload")'') ]; }
        # Binde (repeating)
          { _args = [ (lua "\"XF86AudioRaiseVolume\"") (lua ''hl.dsp.exec_cmd("pactl set-sink-volume @DEFAULT_SINK@ +10%")'')   { repeating = true; } ]; }
          { _args = [ (lua "\"XF86AudioLowerVolume\"") (lua ''hl.dsp.exec_cmd("pactl set-sink-volume @DEFAULT_SINK@ -10%")'')   { repeating = true; } ]; }
          { _args = [ (lua "\"XF86MonBrightnessUp\"")  (lua ''hl.dsp.exec_cmd("brightnessctl s 5%+")'')                         { repeating = true; } ]; }
          { _args = [ (lua "\"XF86MonBrightnessDown\"") (lua ''hl.dsp.exec_cmd("brightnessctl s 5%-")'')                        { repeating = true; } ]; }
        # Bindm (mouse)
          { _args = [ (lua "mod .. \" + mouse:272\"") (lua "hl.dsp.window.drag()")   { mouse = true; } ]; }
          { _args = [ (lua "mod .. \" + mouse:273\"") (lua "hl.dsp.window.resize()") { mouse = true; } ]; }
        # Bindl (locked)
          { _args = [ (lua "\"XF86AudioMute\"")    (lua ''hl.dsp.exec_cmd("pactl set-sink-mute @DEFAULT_SINK@ toggle")'')     { locked = true; } ]; }
          { _args = [ (lua "\"XF86AudioMicMute\"") (lua ''hl.dsp.exec_cmd("pactl set-source-mute @DEFAULT_SOURCE@ toggle")'') { locked = true; } ]; }
        ]
        ++ (optionals sshConfig.enable [
          { _args = [ (lua "mod .. \" + SHIFT + Return\"") (lua "hl.dsp.exec_cmd(terminal .. \" -e ssh ${sshConfig.userName}@${sshConfig.domainName}\")") ]; }
        ]);
      };

      extraConfig = ''
        -- Autostart apps
        hl.on("hyprland.start", function()
          hl.exec_cmd("hyprctl dispatch workspace 1")
          hl.exec_cmd("hyprpaper")
          hl.exec_cmd("waybar")
          hl.exec_cmd("swaync")
        end)
        '' + lib.optionalString (osConfig.fndx.graphical.hidpi) ''
        hl.monitor({
          output = "",
          mode = "preferred",
          position = "auto",
          scale = 1.5
        })
        '';
    };

    programs.hyprlock = {
      enable = true;
      settings = {
        general = {
          no_fade_in = false;
          grace = 0;
          disable_loading_bar = true;
        };
        background = [
          {
            path = "screenshot";
            blur_passes = 3;
            blur_size = 8;
          }
        ];
        input-field = [
          {
            size = "200, 50";
            position = "0, -80";
            monitor = "";
            dots_center = true;
            fade_on_empty = false;
            font_color = "rgb(202, 211, 245)";
            inner_color = "rgb(91, 96, 120)";
            outer_color = "rgb(24, 25, 38)";
            outline_thickness = 5;
            placeholder_text = "Password...";
            shadow_passes = 2;
          }
        ];
      };
    };
  };
}
