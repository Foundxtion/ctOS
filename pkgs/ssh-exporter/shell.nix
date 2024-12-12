{ pkgs ? import <nixpkgs> {} }:
(pkgs.mkShell {
  name = "pip-env";
  nativeBuildInputs = with pkgs; [
    python3
    python3Packages.pip
    python3Packages.virtualenv
    stdenv.cc
    zlib
    gnumake
    black
    systemd
  ];

  shellHook = ''
    export LD_LIBRARY_PATH=${pkgs.lib.makeLibraryPath [
        pkgs.stdenv.cc.cc
        pkgs.zlib
    ]};
  '';
})
