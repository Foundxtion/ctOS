{ lib, runCommand, librsvg, python3 }:
runCommand "ctos-macos-plymouth-theme" {
  nativeBuildInputs = [ librsvg python3 ];
  meta = {
    description = "Apple-style ctOS boot splash and original synthesized startup chime";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
  };
} ''
  themeDir="$out/share/plymouth/themes/ctos-macos"
  mkdir -p "$themeDir" "$out/share/sounds"
  # Render the vector at each supported display size. Plymouth's bilinear
  # downsampling of a large PNG drops coverage along the logo's curved edges.
  for size in {96..256..16}; do
    rsvg-convert -w "$size" -h "$size" ${./logo.svg} > "$themeDir/logo-$size.png"
  done
  rsvg-convert ${./progress-track.svg} > "$themeDir/progress-track.png"
  rsvg-convert ${./progress-fill.svg} > "$themeDir/progress-fill.png"
  cp ${./ctos-macos.script} "$themeDir/ctos-macos.script"
  cat > "$themeDir/ctos-macos.plymouth" <<EOF
  [Plymouth Theme]
  Name=ctOS macOS
  Description=White Apple-style logo and boot progress on black
  ModuleName=script

  [script]
  ImageDir=$themeDir
  ScriptFile=$themeDir/ctos-macos.script
  EOF
  python3 ${./make-chime.py} "$out/share/sounds/ctos-startup.wav"
''
