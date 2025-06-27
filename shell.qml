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
        
        // Simple persistent property for selected tab
        property int persistentSelectedTab: 0

        onVisibleChanged: {
            if (visible) {
                console.log("CheatSheet window became visible, triggering reload...")
                cheatSheet.reloadConfig()
            } else {
                // Save current tab when hiding
                persistentSelectedTab = cheatSheet.getCurrentTab()
                console.log("Saved selected tab:", persistentSelectedTab)
            }
        }

        Connections {
            target: cheatSheet
            function onTabsLoaded() {
                console.log("Received tabsLoaded signal, restoring tab:", cheatSheetWindow.persistentSelectedTab)
                cheatSheet.restoreSelectedTab(cheatSheetWindow.persistentSelectedTab)
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
