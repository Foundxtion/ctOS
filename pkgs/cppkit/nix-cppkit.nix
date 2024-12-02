{config, lib, pkgs, ...}:
let
  cfg = config.fndx.packages.cppkit;
in
with lib;
{
    options = {
        fndx.packages.cppkit.enable = mkEnableOption "Cpp development kit for ctOS";
    };

    config = mkIf cfg.enable {
        environment.systemPackages = with pkgs; [
            clang
            clang-tools
            gcc
            gnumake
            cmake
            # jetbrains.clion
        ];
    };
}
