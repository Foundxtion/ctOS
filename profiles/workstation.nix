{config, lib, pkgs, ...}:
let
    cfg = config.fndx.workstation;
in
with lib;
{
    options = {
        fndx.workstation.enable = mkEnableOption "Foundxtion workstation Profile";
    };

    config = mkIf cfg.enable {
        fndx.graphical = {
            enable = true;
            type = "plasma";
        };

        fndx.packages.vscode.enable = true;
        fndx.packages.discord.enable = true;

        environment.systemPackages = with pkgs; [
            obsidian
        ];
    };
}
