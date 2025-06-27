import QtQuick 2.15
import QtQuick.Controls 2.15
import Quickshell 0.1
import Quickshell.Hyprland 0.1

ShellRoot {
    Window {
        id: cheatSheetWindow

        width: cheatSheet.implicitWidth
        height: cheatSheet.implicitHeight
        title: "Quickshell Cheatsheet"

        visible: false

        onVisibleChanged: {
            if (visible) {
                console.log("CheatSheet window became visible, triggering reload...")
                cheatSheet.reloadConfig()
            }
        }

        CheatSheet {
            id: cheatSheet
        }
    }

    GlobalShortcut {
        appid: "quickshell"
        name: "cheatsheet_toggle"

        onPressed: {
            cheatSheetWindow.visible = !cheatSheetWindow.visible
        }
    }
}
