import Quickshell

import "root:/modules"

// Entry point. Quickshell looks for shell.qml in the folder you point it
// at (or ~/.config/quickshell/<name>/shell.qml) — everything else is
// pulled in from here via root:/ imports, so this file stays tiny.
ShellRoot {
    Bar {}
}
