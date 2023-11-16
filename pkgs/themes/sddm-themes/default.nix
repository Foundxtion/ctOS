{ lib
, qtbase
, qtsvg
, qtgraphicaleffects
, qtquickcontrols2
, wrapQtAppsHook
, stdenvNoCC
, fetchFromGitHub
}: 
{
    sddm-chili = stdenvNoCC.mkDerivation rec {
        pname = "sddm-chili";
        version = "0.1.5";
        dontBuild = true;
        src = fetchFromGitHub {
            owner = "MarianArlt";
            repo = "sddm-chili";
            rev = "refs/tags/${version}";
            sha256 = "wxWsdRGC59YzDcSopDRzxg8TfjjmA3LHrdWjepTuzgw=";
        };
        nativeBuildInputs = [
            wrapQtAppsHook
        ];

        propagatedUserEnvPkgs = [
            qtbase
            qtsvg
            qtgraphicaleffects
            qtquickcontrols2
        ];


        installPhase = ''
        mkdir -p $out/share/sddm/themes
        cp -aR $src $out/share/sddm/themes/sddm-chili
        '';

    };
}
