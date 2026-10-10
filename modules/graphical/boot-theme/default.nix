{ lib, runCommand, librsvg, waitForChime ? false }:
runCommand "ctos-plymouth-theme" {
  nativeBuildInputs = [ librsvg ];
  meta = {
    description = "Apple-style ctOS boot splash";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
  };
} ''
  themeDir="$out/share/plymouth/themes/ctos"
  mkdir -p "$themeDir"
  # Render the vector at each supported display size. Plymouth's bilinear
  # downsampling of a large PNG drops coverage along the logo's curved edges.
  for size in {96..256..16}; do
    rsvg-convert -w "$size" -h "$size" ${./logo.svg} > "$themeDir/logo-$size.png"
  done
  rsvg-convert ${./progress-track.svg} > "$themeDir/progress-track.png"
  rsvg-convert ${./progress-fill.svg} > "$themeDir/progress-fill.png"
  substitute ${./ctos.script} "$themeDir/ctos.script" \
    --replace-fail @waitForChime@ ${if waitForChime then "1" else "0"}
  cat > "$themeDir/ctos.plymouth" <<EOF
  [Plymouth Theme]
  Name=ctOS
  Description=White logo and boot progress on black
  ModuleName=script

  [script]
  ImageDir=$themeDir
  ScriptFile=$themeDir/ctos.script
  EOF
''
