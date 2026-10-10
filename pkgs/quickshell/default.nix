{pkgs ? import <nixpkgs> {} }:
let
	configPath = ./quickshell-config;
	execution = "exec ${pkgs.quickshell}/bin/quickshell -p ${configPath}";
in
pkgs.writeShellScriptBin "fndx-quickshell" execution
