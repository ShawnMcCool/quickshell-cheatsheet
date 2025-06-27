# QuickShell Cheat Sheet

A customizable, keyboard-driven cheat sheet system for QuickShell. Displays your frequently used commands, keybindings, and reference information in a clean, tabbed interface with dynamic sizing and scrollable content.

![demo](https://raw.githubusercontent.com/ShawnMcCool/quickshell-cheatsheet/refs/heads/main/demo.gif)

## Features

- **Tabbed Interface**: Organize commands into logical groups
- **Dynamic Sizing**: Window automatically sizes to fit content
- **Scrollable Content**: Long lists scroll smoothly with keyboard controls
- **Customizable Keybindings**: Configure all navigation keys
- **QT Theming**

## Installation

1. **Copy Files**: Place `CheatSheet.qml` in `.config/quickshell`.
2. **Add a Config**: Called `cheatsheet.json` in the same directory.
3. **Trigger from Hyprland**: (or wherever) `bind = $mainMod, grave, global, quickshell:cheatsheet_toggle`

## Configuration

### Config File Locations

The cheat sheet automatically searches for `cheatsheet.json` in the following locations (in order):

1. **Custom Path**: If `configFilePath` property is set
2. **Relative to QML**: Same directory as `CheatSheet.qml`
3. **User Config**: `~/.config/quickshell/cheatsheet.json`
4. **Current Directory**: `./cheatsheet.json`

If no config file is found, comprehensive fallback data is used.

## Example

```json
{
    "title": "Cheat Sheet",
    "navigation": {
        "prev_tab": ["Left", "H", "A", "h"],
        "next_tab": ["Right", "L", "D", "s"],
        "scroll_up": ["n", "N"],
        "scroll_down": ["t", "T"]
    },
    "tabs": {
        "Display": [
            {
                "cmd": "Ctrl + 1",
                "desc": "Copy Region"
            },
            {
                "cmd": "Ctrl + 2",
                "desc": "Copy Region w/ Delay"
            },
            {
                "cmd": "Ctrl + 3",
                "desc": "Copy Tile"
            },
            {
                "cmd": "Ctrl + 4",
                "desc": "Copy Animation"
            },
            {
                "cmd": "Ctrl + 5",
                "desc": "Color Picker"
            }
        ],
        "Git": [
            {
                "cmd": "Alt + S",
                "desc": "Working Tree Status"
            },
            {
                "cmd": "Alt + E",
                "desc": "Stage Files"
            },
            {
                "cmd": "Ctrl + E",
                "desc": "Unstage Files"
            },
            {
                "cmd": "Alt + C",
                "desc": "Add and Commit All"
            },
            {
                "cmd": "Alt + P",
                "desc": "Push Changes"
            },
            {
                "cmd": "Alt + L",
                "desc": "Show Logs"
            },
            {
                "cmd": "Alt + F",
                "desc": "Create Feature Branch"
            },
            {
                "cmd": "Alt + S",
                "desc": "Working Tree Status"
            },
            {
                "cmd": "Alt + E",
                "desc": "Stage Files"
            },
            {
                "cmd": "Ctrl + E",
                "desc": "Unstage Files"
            },
            {
                "cmd": "Alt + C",
                "desc": "Add and Commit All"
            },
            {
                "cmd": "Alt + P",
                "desc": "Push Changes"
            },
            {
                "cmd": "Alt + L",
                "desc": "Show Logs"
            }
        ],
        "Session Log": [
            {
                "cmd": "session_log_info",
                "desc": "Show terminal session log info"
            },
            {
                "cmd": "show_session_log",
                "desc": "Show terminal session log"
            },
            {
                "cmd": "show_clean_log",
                "desc": "Show clean terminal session log"
            },
            {
                "cmd": "grep_session_log [clean] <pattern>",
                "desc": "Search session log with pattern"
            }
        ]
    }
}
```

## Default Keybindings

### Navigation

- **Escape**: Close cheat sheet
- **h, A, Left Arrow**: Previous tab
- **s, D, Right Arrow**: Next tab
- **n, N**: Scroll up
- **t, T**: Scroll down

All keybindings are customizable through the `navigation` section in your config file.

## Embed in Existing Shell

Add to your existing `shell.qml`:

```qml
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
```

## Dependencies

- QuickShell
- Qt 5.15+ or Qt 6.0+
- QtQuick.Controls with Material theme support
