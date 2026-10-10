{ pkgs, background }:
(pkgs.sddm-chili-theme.override {
  # Interpolation copies local wallpaper paths into the store.
  themeConfig.background = "${background}";
}).overrideAttrs (old: {
  postPatch = (old.postPatch or "") + ''
    cp ${./Main.qml} Main.qml
    cp ${./LoginFormLayout.qml} components/LoginFormLayout.qml
    substituteInPlace components/UserList.qml \
      --replace-fail 'avatarSize + passwordField.height / 2' 'avatarSize + rootFontSize * 3'
    substituteInPlace components/LoginForm.qml \
      --replace-fail 'implicitWidth: root.width / 5' 'implicitWidth: Math.max(220, Math.min(360, root.width / 5))'
    substituteInPlace components/ActionButton.qml \
      --replace-fail 'anchors.top: parent.bottom' "" \
      --replace-fail 'anchors.topMargin: icon.height' "" \
      --replace-fail 'Math.max(icon.implicitWidth, label.contentWidth)' 'Math.max(icon.width, label.contentWidth)' \
      --replace-fail 'Math.max(icon.implicitHeight + label.height * 2, label.height)' 'icon.height + label.height * 2'
    substituteInPlace components/SessionMenu.qml \
      --replace-fail 'instantiator.objectAt(currentIndex).text || ""' '(instantiator.objectAt(currentIndex) ? instantiator.objectAt(currentIndex).text : "")'
  '';
})
