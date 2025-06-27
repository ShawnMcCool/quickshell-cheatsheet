import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Layouts 1.15
import Quickshell 0.1
import Quickshell.Io 0.1

Item {
    id: root
    focus: true
    
    signal tabsLoaded()
    
    // Dynamic sizing based on content
    implicitWidth: root.calculatedWidth > 0 ? root.calculatedWidth : 600
    implicitHeight: root.finalHeight > 0 ? root.finalHeight : 400
    
    width: implicitWidth
    height: implicitHeight
    
    // Configure Material theme to auto-detect system dark/light mode
    Material.theme: Material.System
    Material.accent: Material.Purple
    
    // System palette for automatic color detection
    SystemPalette {
        id: systemPalette
        colorGroup: SystemPalette.Active
    }

    Keys.onEscapePressed: {
        cheatSheetWindow.visible = false
    }

    Keys.onPressed: function(event) {
        var key = event.text

        // Check for previous tab navigation
        if (key && root.navigationKeys.prev_tab && root.navigationKeys.prev_tab.includes(key)) {
            navigateToPrevTab()
            event.accepted = true
            return
        }

        // Check for next tab navigation
        if (key && root.navigationKeys.next_tab && root.navigationKeys.next_tab.includes(key)) {
            navigateToNextTab()
            event.accepted = true
            return
        }

        // Check for scroll up navigation
        if (key && root.navigationKeys.scroll_up && root.navigationKeys.scroll_up.includes(key)) {
            scrollUp()
            event.accepted = true
            return
        }

        // Check for scroll down navigation
        if (key && root.navigationKeys.scroll_down && root.navigationKeys.scroll_down.includes(key)) {
            scrollDown()
            event.accepted = true
            return
        }

        // Handle special keys by key code
        if (event.key === Qt.Key_Left && root.navigationKeys.prev_tab.includes("Left")) {
            navigateToPrevTab()
            event.accepted = true
        } else if (event.key === Qt.Key_Right && root.navigationKeys.next_tab.includes("Right")) {
            navigateToNextTab()
            event.accepted = true
        } else if (event.key === Qt.Key_F5) {
            // F5 to manually reload data from JSON file
            console.log("Manual reload triggered")
            loadJsonFile()
            event.accepted = true
        } else if (event.key === Qt.Key_F6) {
            // F6 to cycle through Material themes
            console.log("Theme switch triggered")
            cycleTheme()
            event.accepted = true
        }
    }

    function navigateToPrevTab() {
        if (tabBar && root.tabNames.length > 0) {
            tabBar.currentIndex = (tabBar.currentIndex - 1 + root.tabNames.length) % root.tabNames.length
        }
    }

    function navigateToNextTab() {
        if (tabBar && root.tabNames.length > 0) {
            tabBar.currentIndex = (tabBar.currentIndex + 1) % root.tabNames.length
        }
    }

    function scrollUp() {
        var currentListView = getCurrentListView()
        if (currentListView) {
            var scrollAmount = 7 * 40 // 7 lines * 40px per line = 280px
            var newY = Math.max(0, currentListView.contentY - scrollAmount)
            currentListView.contentY = newY
            console.log("Scrolling up, contentY:", newY)
        }
    }

    function scrollDown() {
        var currentListView = getCurrentListView()
        if (currentListView) {
            var scrollAmount = 7 * 40 // 7 lines * 40px per line = 280px
            var maxY = Math.max(0, currentListView.contentHeight - currentListView.height)
            var newY = Math.min(maxY, currentListView.contentY + scrollAmount)
            currentListView.contentY = newY
            console.log("Scrolling down, contentY:", newY)
        }
    }

    function getCurrentListView() {
        if (stackLayout && stackLayout.children && tabBar.currentIndex >= 0 && tabBar.currentIndex < stackLayout.children.length) {
            return stackLayout.children[tabBar.currentIndex]
        }
        return null
    }
    
    function cycleTheme() {
        // Cycle through Material themes: System -> Dark -> Light -> System
        if (Material.theme === Material.System) {
            Material.theme = Material.Dark
            console.log("Switched to Dark theme")
        } else if (Material.theme === Material.Dark) {
            Material.theme = Material.Light  
            console.log("Switched to Light theme")
        } else {
            Material.theme = Material.System
            console.log("Switched to System theme")
        }
    }

    property var cheatSheetData: ({})
    property var tabNames: []
    property var navigationKeys: ({
        "prev_tab": ["Left", "H", "A"],
        "next_tab": ["Right", "L", "D"]
    })
    property string sheetTitle: "Cheat Sheet"
    property bool jsonLoadSuccess: false
    property real maxCmdWidth: 0
    property real maxDescWidth: 0
    property real calculatedWidth: 0
    property real calculatedHeight: 0
    property int maxItemCount: 0
    property real maxHeight: 600 // Maximum window height before scrolling kicks in
    property real finalHeight: 0
    property string configFilePath: "" // Allow override of config file path
    property var configPaths: [] // List of paths to try in order

    // TextMetrics for measuring text dimensions
    TextMetrics {
        id: cmdTextMetrics
        font.pixelSize: 16
        font.bold: true
    }

    TextMetrics {
        id: descTextMetrics  
        font.pixelSize: 16
    }

    TextMetrics {
        id: titleTextMetrics
        font.pixelSize: 24
        font.bold: true
        text: "Cheat Sheet"
    }

    Component.onCompleted: {
        console.log("Component completed, initializing config paths...")
        initializeConfigPaths()
        loadJsonFile()
    }

    function reloadConfig() {
        console.log("Reloading config...")
        root.configLoadSuccess = false // Reset success flag to allow reload
        loadJsonFile()
    }

    function getCurrentTab() {
        return tabBar.currentIndex
    }

    function restoreSelectedTab(index) {
        if (index >= 0 && index < root.tabNames.length) {
            tabBar.currentIndex = index
            console.log("Restored tab selection to index:", index)
        }
    }

    function initializeConfigPaths() {
        // Initialize the list of paths to try, in order of preference
        root.configPaths = []
        
        // 1. User-specified path (if provided)
        if (root.configFilePath && root.configFilePath !== "") {
            root.configPaths.push(root.configFilePath)
            console.log("Added user-specified path:", root.configFilePath)
        }
        
        // 2. Relative to QML file location
        try {
            var relativePath = Qt.resolvedUrl("cheatsheet.json").toString()
            if (relativePath && relativePath !== "cheatsheet.json") {
                root.configPaths.push(relativePath)
                console.log("Added relative path:", relativePath)
            }
        } catch (e) {
            console.log("Failed to resolve relative path:", e)
        }
        
        // 3. User's config directory - try both tilde and absolute paths
        root.configPaths.push("~/.config/quickshell/cheatsheet.json")
        console.log("Added home config path with tilde: ~/.config/quickshell/cheatsheet.json")
        
        // Also try absolute path using cat's ability to read from shell expansion
        root.configPaths.push("$HOME/.config/quickshell/cheatsheet.json")
        console.log("Added home config path with $HOME: $HOME/.config/quickshell/cheatsheet.json")
        
        // 4. Current working directory
        root.configPaths.push("./cheatsheet.json")
        console.log("Added current directory path: ./cheatsheet.json")
        
        console.log("Initialized config paths:", JSON.stringify(root.configPaths))
    }

    property int currentPathIndex: 0
    property bool configLoadSuccess: false

    function loadJsonFile() {
        root.currentPathIndex = 0
        root.configLoadSuccess = false
        tryNextConfigPath()
    }
    
    function tryNextConfigPath() {
        if (root.configLoadSuccess) {
            console.log("Config already loaded successfully, skipping further attempts")
            return
        }
        
        if (root.currentPathIndex >= root.configPaths.length) {
            console.log("All config paths failed, loading fallback data")
            loadFallbackData()
            return
        }
        
        var currentPath = root.configPaths[root.currentPathIndex]
        console.log("Trying config path:", currentPath, "(attempt", root.currentPathIndex + 1, "of", root.configPaths.length + ")")
        
        // Update the command for the current path - use shell for path expansion
        var cleanPath = currentPath.replace("file://", "")
        if (cleanPath.startsWith("~") || cleanPath.startsWith("$")) {
            // Use shell expansion for ~ and $ paths
            jsonFileReader.command = ["sh", "-c", "cat " + cleanPath]
        } else {
            // Direct cat command for absolute paths
            jsonFileReader.command = ["cat", cleanPath]
        }
        jsonFileReader.running = true
    }

    Process {
        id: jsonFileReader
        command: ["cat", ""] // Will be set dynamically
        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                var currentPath = (root.configPaths && root.currentPathIndex < root.configPaths.length) ? 
                                  root.configPaths[root.currentPathIndex] : "unknown"
                console.log("JSON file content received from", currentPath, "- length:", this.text.length)
                try {
                    var jsonData = JSON.parse(this.text)
                    root.cheatSheetData = jsonData
                    root.jsonLoadSuccess = true
                    root.configLoadSuccess = true // Mark config as successfully loaded

                    // Extract navigation keys if present
                    if (jsonData.navigation) {
                        root.navigationKeys = jsonData.navigation
                        console.log("Loaded navigation keys:", JSON.stringify(root.navigationKeys))
                    }

                    // Extract title if present
                    if (jsonData.title) {
                        root.sheetTitle = jsonData.title
                        console.log("Loaded title:", root.sheetTitle)
                    }

                    // Get tab names from tabs section, or fallback to old method
                    if (jsonData.tabs) {
                        root.tabNames = Object.keys(jsonData.tabs)
                        console.log("Using tabs section for tab names")
                    } else {
                        // Fallback to old method for backward compatibility
                        root.tabNames = Object.keys(root.cheatSheetData).filter(key => key !== "navigation" && key !== "title")
                        console.log("Using root level for tab names (backward compatibility)")
                    }
                    console.log("Successfully loaded config from:", currentPath)
                    console.log("Loaded tabs:", root.tabNames)
                    
                    // Calculate content dimensions
                    calculateMaxWidths()
                    
                    // Signal that tabs are loaded
                    root.tabsLoaded()
                } catch (e) {
                    var currentPath = (root.configPaths && root.currentPathIndex < root.configPaths.length) ? 
                                      root.configPaths[root.currentPathIndex] : "unknown"
                    console.log("Failed to parse JSON from", currentPath + ":", e)
                    root.currentPathIndex++
                    tryNextConfigPath()
                }
            }
        }

        stderr: StdioCollector {
            onStreamFinished: {
                // Don't continue if we already successfully loaded config
                if (root.configLoadSuccess) {
                    return
                }
                
                var currentPath = (root.configPaths && root.currentPathIndex < root.configPaths.length) ? 
                                  root.configPaths[root.currentPathIndex] : "unknown"
                if (this.text && this.text.length > 0) {
                    console.log("Error reading config file", currentPath + ":", this.text)
                } else {
                    console.log("Config file not found:", currentPath)
                }
                root.currentPathIndex++
                tryNextConfigPath()
            }
        }
    }

    
    function calculateMaxWidths() {
        root.maxCmdWidth = 0
        root.maxDescWidth = 0
        root.maxItemCount = 0
        
        // Iterate through all tabs and items to find maximum widths and item count
        for (var tabName of root.tabNames) {
            var tabData = (root.cheatSheetData.tabs && root.cheatSheetData.tabs[tabName]) ? 
                         root.cheatSheetData.tabs[tabName] : 
                         (root.cheatSheetData[tabName] || [])
            root.maxItemCount = Math.max(root.maxItemCount, tabData.length)
            
            for (var i = 0; i < tabData.length; i++) {
                var item = tabData[i]
                
                // Measure cmd text width
                if (item.cmd) {
                    cmdTextMetrics.text = item.cmd
                    root.maxCmdWidth = Math.max(root.maxCmdWidth, cmdTextMetrics.width)
                }
                
                // Measure desc text width  
                if (item.desc) {
                    descTextMetrics.text = item.desc
                    root.maxDescWidth = Math.max(root.maxDescWidth, descTextMetrics.width)
                }
            }
        }
        
        // Calculate total required width with margins and padding
        var leftMargin = 20
        var rightMargin = 20
        var spacing = 40 // Space between cmd and desc columns
        var minTitleWidth = titleTextMetrics.width + 20 // Title + padding
        
        root.calculatedWidth = Math.max(
            root.maxCmdWidth + root.maxDescWidth + leftMargin + rightMargin + spacing,
            minTitleWidth,
            400 // Minimum width
        )
        
        // Calculate required height
        var titleHeight = 64 // Title with padding
        var tabBarHeight = 48 // TabBar height
        var itemHeight = 40 // Height per item
        var padding = 20 // Bottom padding
        
        root.calculatedHeight = titleHeight + tabBarHeight + (root.maxItemCount * itemHeight) + padding
        
        // Apply maximum height constraint
        root.finalHeight = Math.min(root.calculatedHeight, root.maxHeight)
        
        console.log("Calculated dimensions - Cmd:", root.maxCmdWidth, "Desc:", root.maxDescWidth, "Width:", root.calculatedWidth, "Height:", root.calculatedHeight, "Final Height:", root.finalHeight, "Items:", root.maxItemCount)
    }

    function loadFallbackData() {
        console.log("Loading comprehensive fallback data...")
        root.cheatSheetData = {
            "tabs": {
                "Navigation": [
                    {"cmd": "Escape", "desc": "Close cheat sheet"},
                    {"cmd": "F5", "desc": "Reload configuration"},
                    {"cmd": "F6", "desc": "Cycle theme (System/Dark/Light)"},
                    {"cmd": "h/A/Left", "desc": "Previous tab"},
                    {"cmd": "s/D/Right", "desc": "Next tab"},
                    {"cmd": "n/N", "desc": "Scroll up"},
                    {"cmd": "t/T", "desc": "Scroll down"}
                ],
                "Example Commands": [
                    {"cmd": "Ctrl + C", "desc": "Copy to clipboard"},
                    {"cmd": "Ctrl + V", "desc": "Paste from clipboard"},
                    {"cmd": "Ctrl + Z", "desc": "Undo last action"},
                    {"cmd": "Ctrl + Y", "desc": "Redo last action"},
                    {"cmd": "Ctrl + S", "desc": "Save file"},
                    {"cmd": "Ctrl + O", "desc": "Open file"},
                    {"cmd": "Ctrl + N", "desc": "New file"},
                    {"cmd": "Ctrl + W", "desc": "Close tab/window"}
                ],
                "Configuration": [
                    {"cmd": "cheatsheet.json", "desc": "Main configuration file"},
                    {"cmd": "configFilePath property", "desc": "Override config file location"},
                    {"cmd": "navigation section", "desc": "Customize keybindings"},
                    {"cmd": "maxHeight property", "desc": "Set maximum window height"}
                ]
            }
        }
        
        // Set navigation keys for fallback
        root.navigationKeys = {
            "prev_tab": ["Left", "H", "A", "h"],
            "next_tab": ["Right", "L", "D", "s"],
            "scroll_up": ["n", "N"],
            "scroll_down": ["t", "T"]
        }
        
        root.tabNames = ["Navigation", "Example Commands", "Configuration"]
        console.log("Comprehensive fallback data loaded - no config file found")
        
        // Calculate content dimensions for fallback data
        calculateMaxWidths()
        
        // Signal that tabs are loaded for fallback data too
        root.tabsLoaded()
    }

    Rectangle {
        anchors.fill: parent
        color: Material.backgroundColor

        ColumnLayout {
            id: contentColumn
            anchors.fill: parent
            spacing: 0

            Text {
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredHeight: implicitHeight + 20
                text: root.sheetTitle
                color: Material.foreground
                font.pixelSize: 24
                font.bold: true
                padding: 10
            }

            TabBar {
                id: tabBar
                Layout.fillWidth: true
                Layout.preferredHeight: implicitHeight
                currentIndex: 0

                Repeater {
                    model: root.tabNames
                    TabButton {
                        text: modelData
                        
                    }
                }
            }

            StackLayout {
                id: stackLayout
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredWidth: root.calculatedWidth > 0 ? root.calculatedWidth : 600
                Layout.minimumWidth: 400
                currentIndex: tabBar.currentIndex

                Repeater {
                    model: root.tabNames
                    ListView {
                        width: parent.width
                        height: parent.height
                        model: (root.cheatSheetData.tabs && root.cheatSheetData.tabs[modelData]) ? 
                               root.cheatSheetData.tabs[modelData] : 
                               (root.cheatSheetData[modelData] || [])
                        
                        // Enable scrolling
                        clip: true
                        boundsBehavior: Flickable.StopAtBounds
                        
                        // Add scroll indicators
                        ScrollBar.vertical: ScrollBar {
                            active: parent.contentHeight > parent.height
                            policy: ScrollBar.AsNeeded
                        }

                        delegate: Item {
                            width: parent.width
                            height: 40

                            Rectangle {
                                anchors.fill: parent
                                color: Material.accent
                                opacity: 0.1
                                visible: index % 2 === 0
                            }

                            Text {
                                id: cmdText
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                anchors.leftMargin: 20
                                
                                // Use a fixed width based on calculated max, avoiding binding loops
                                property real calculatedWidth: root.maxCmdWidth > 0 ? root.maxCmdWidth : 150
                                width: calculatedWidth

                                text: modelData.cmd || ""
                                color: Material.accent
                                font.pixelSize: 16
                                font.bold: true
                                elide: Text.ElideRight
                            }

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: cmdText.right
                                anchors.leftMargin: 40
                                anchors.right: parent.right
                                anchors.rightMargin: 20

                                text: modelData.desc || ""
                                color: Material.foreground
                                font.pixelSize: 16
                                wrapMode: Text.WordWrap
                            }
                        }
                    }
                }
            }
        }
    }
}
