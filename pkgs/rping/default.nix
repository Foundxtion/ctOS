{ pkgs ? import <nixpkgs> {} }:
let
	repo = builtins.fetchGit {
		url = "https://github.com/Foundxtion/rping";
		ref = "main";
		rev = "e2e12e8151a59bada4750d5bf4a42b9ceb233d5f";
	};
	src = pkgs.lib.cleanSource repo;
	cargo_lock = repo + "/Cargo.lock";
	cargo_toml = repo + "/Cargo.toml";
	manifest = (pkgs.lib.importTOML cargo_toml).package;

in
pkgs.rustPlatform.buildRustPackage {
	pname = manifest.name;
	version = manifest.version;
	cargoLock.lockFile = cargo_lock;
	inherit src;

	buildInputs = with pkgs; [
		openssl
		krb5Full
		(llvmPackages.libclang.lib)
	];

	nativeBuildInputs = with pkgs; [
		(llvmPackages.clang)
		pkg-config
	];

	env = {
		LIBCLANG_PATH = "${pkgs.llvmPackages.libclang.lib}/lib";
	};

	release = true;

	meta = with pkgs.lib; {
		description = "A reverse DNS util for Founxtion platforms";
		homepage = "https://github.com/Foundxtion/rping";
		licence = licence.gpl3Only;
		platforms = platforms.linux;
	};
}
