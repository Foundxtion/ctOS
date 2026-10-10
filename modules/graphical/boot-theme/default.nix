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
  rsvg-convert -w 512 -h 512 ${./logo.svg} > "$themeDir/logo.png"
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
