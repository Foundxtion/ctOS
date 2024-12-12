{config, lib, pkgs, ...}:
let
    cfg = config.fndx.packages.nautilus;
    gdk_scaler = "export GDK_SCALE=2;";
    nautilus_exec = "exec ${pkgs.nautilus}/bin/nautilus;";
in
with lib;
{
    options.fndx.packages.nautilus.enable = mkEnableOption "Nautilus for ctOS";

    config = mkIf cfg.enable {
        environment.systemPackages = let
            wrapped = pkgs.writeShellScriptBin "nautilus" (lib.strings.concatStringsSep "\n" ( 
            (optionals (config.fndx.graphical.hidpi) [gdk_scaler]) 
            ++ [nautilus_exec]));
        in
        with pkgs; [
            (symlinkJoin {
                name = "nautilus";
                paths = [
                    wrapped
                    nautilus
                ];
            })
        ];

        services.gvfs.enable = mkIf config.fndx.packages.i3.enable true;
        xdg.mime = mkIf config.fndx.packages.i3.enable {
            addedAssociations = {
                # This shouldn't be necessary, but just for good measure...
                "inode/directory" = "org.gnome.Nautilus.desktop";
            };
            defaultApplications = {
                "inode/directory" = "org.gnome.Nautilus.desktop";
            };
        };
    };
}
