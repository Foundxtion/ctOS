with import <nixpkgs> {};
stdenv.mkDerivation {
  name = "env";
  nativeBuildInputs = [ 
  ];
  buildInputs = [
    qemu
  ];
  # shellHook = ''
  #   cd ../
  #   nix-build '<nixpkgs/nixos' -A config.system.build.isoImage -I nixos-config=builder/iso.nix;
  #   qemu-system-x86_64 -enable-kvm -m 256 -cdrom result/iso/nixos-*.iso;
  # '';
}
