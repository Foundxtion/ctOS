{config, lib, pkgs, ...}:
let
    cfg = config.fndx.dev;
in
with lib;
{
    options = {
        fndx.dev.enable = mkEnableOption "ctOS Dev Profile";
        fndx.dev.cpp.enable = mkEnableOption "ctOS C/C++ development profile";
        fndx.dev.csharp.enable = mkEnableOption "ctOS C# development profile";
        fndx.dev.java.enable = mkEnableOption "ctOS Java development profile";
        fndx.dev.rust.enable = mkEnableOption "ctOS Rust development profile";
        fndx.dev.web.enable = mkEnableOption "ctOS Web development profile";
    };

    config = mkIf cfg.enable {
        fndx.graphical = {
            enable = true;
            type = "i3";
        };
        fndx.packages.vscode.enable = true;
        fndx.packages.discord.enable = true;

        fndx.packages.cppkit.enable = cfg.cpp.enable;
        fndx.packages.csharpkit.enable = cfg.csharp.enable;
        fndx.packages.javakit.enable = cfg.java.enable;
        fndx.packages.webkit.enable = cfg.web.enable;
        fndx.packages.rustkit.enable = cfg.rust.enable;

        environment.systemPackages = with pkgs; [
            thunderbird
            obsidian
            cider
            libreoffice-qt
        ];
    };
}
