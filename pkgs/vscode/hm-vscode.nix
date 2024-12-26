{osConfig, lib, pkgs, ...}:
with lib;
{
    programs.vscode = mkIf osConfig.fndx.packages.vscode.enable {
        enable = true;
        extensions = with pkgs.vscode-extensions; [
            vscodevim.vim
        ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
            {
                name = "jetbrains-rider-dark-theme";
                publisher = "EdwinSulaiman";
                version = "1.0.2";
            }

            {
                name = "vscode-jetbrains-icon-theme";
                publisher = "chadalen";
                version = "2.24.0";
            }

            {
                name = "vscode-typescript-next";
                publisher = "ms-vscode";
                version = "5.8.20241225";
            }
        ];
    };
}
