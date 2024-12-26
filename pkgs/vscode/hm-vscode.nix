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
                sha256 = "";
            }

            {
                name = "vscode-jetbrains-rider-icon-theme";
                publisher = "chadalen";
                version = "2.24.0";
                sha256 = "";
            }

            {
                name = "ms-vscode";
                publisher = "vscode-typescript-next";
                version = "5.8.20241225";
                sha256 = "";
            }
        ];
    };
}
