import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// Import the main UI components - these should work in plugins
FocusScope {
    id: worldClockSettings

    property var timezones: []
    property var pluginService: null

    onPluginServiceChanged: {
        console.log("WorldClock: PluginService changed:", pluginService !== null)
        if (pluginService) {
            console.log("WorldClock: PluginService now available, loading timezones")
            loadTimezones()
        }
    }

    onTimezonesChanged: {
        console.log("WorldClock: Timezones property changed:", JSON.stringify(timezones))
    }
    property alias timezoneInput: timezoneInput
    property alias labelInput: labelInput

    focus: true

    implicitHeight: settingsColumn.implicitHeight
    height: implicitHeight

    // Create a custom theme for the plugin
    QtObject {
        id: pluginTheme
        readonly property int spacingL: 20
        readonly property int spacingM: 15
        readonly property int spacingS: 10
        readonly property color surfaceText: "#FFFFFF"
        readonly property color surfaceVariantText: "#CCCCCC"
        readonly property color primary: "#0078D4"
        readonly property color primaryPressed: "#106EBE"
        readonly property color surfaceContainer: "#333333"
        readonly property color outline: "#555555"
        readonly property int fontSizeXLarge: 18
        readonly property int fontSizeMedium: 14
        readonly property int fontSizeSmall: 12
        readonly property int cornerRadius: 4
    }

    Column {
        id: settingsColumn
        anchors.fill: parent
        anchors.margins: pluginTheme.spacingL
        spacing: pluginTheme.spacingM

        Text {
            text: "World Clock Settings"
            font.pixelSize: pluginTheme.fontSizeXLarge
            font.weight: Font.Bold
            color: pluginTheme.surfaceText
        }

        Text {
            text: "Add timezones to display multiple clocks in the bar"
            font.pixelSize: pluginTheme.fontSizeMedium
            color: pluginTheme.surfaceVariantText
            wrapMode: Text.WordWrap
            width: parent.width
        }

        // Input fields section
        Column {
            width: parent.width
            spacing: pluginTheme.spacingS

            // Input labels
            Row {
                width: parent.width
                spacing: pluginTheme.spacingS

                Text {
                    text: "Timezone"
                    font.pixelSize: pluginTheme.fontSizeSmall
                    font.weight: Font.Medium
                    color: pluginTheme.surfaceText
                    width: 200
                }

                Text {
                    text: "Display Label (optional)"
                    font.pixelSize: pluginTheme.fontSizeSmall
                    font.weight: Font.Medium
                    color: pluginTheme.surfaceText
                    width: 100
                }
            }

            // Input fields row
            Row {
                width: parent.width
                spacing: pluginTheme.spacingS

                Rectangle {
                    width: 200
                    height: 40
                    radius: pluginTheme.cornerRadius
                    color: pluginTheme.surfaceContainer
                    border.color: timezoneInput.activeFocus ? pluginTheme.primary : pluginTheme.outline
                    border.width: timezoneInput.activeFocus ? 2 : 1

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            timezoneInput.forceActiveFocus()
                        }
                    }

                    TextInput {
                        id: timezoneInput
                        anchors.fill: parent
                        anchors.margins: 12
                        color: pluginTheme.surfaceText
                        font.pixelSize: pluginTheme.fontSizeMedium
                        verticalAlignment: TextInput.AlignVCenter
                        selectByMouse: true
                        activeFocusOnTab: true
                        focus: true
                        KeyNavigation.tab: labelInput

                        Keys.onReturnPressed: {
                            if (text.trim() !== "") {
                                addTimezone(text.trim(), labelInput.text.trim())
                                text = ""
                                labelInput.text = ""
                            }
                        }

                        Component.onCompleted: {
                            focusDelayTimer.start()
                        }

                        Timer {
                            id: focusDelayTimer
                            interval: 100
                            repeat: false
                            onTriggered: {
                                timezoneInput.forceActiveFocus()
                            }
                        }
                    }

                    Text {
                        anchors.fill: timezoneInput
                        anchors.margins: 12
                        text: "e.g., America/New_York"
                        font.pixelSize: pluginTheme.fontSizeMedium
                        color: pluginTheme.surfaceVariantText
                        verticalAlignment: Text.AlignVCenter
                        visible: timezoneInput.text.length === 0 && !timezoneInput.activeFocus
                    }
                }

                Rectangle {
                    width:  100
                    height: 40
                    radius: pluginTheme.cornerRadius
                    color: pluginTheme.surfaceContainer
                    border.color: labelInput.activeFocus ? pluginTheme.primary : pluginTheme.outline
                    border.width: labelInput.activeFocus ? 2 : 1

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            labelInput.forceActiveFocus()
                        }
                    }

                    TextInput {
                        id: labelInput
                        anchors.fill: parent
                        anchors.margins: 12
                        color: pluginTheme.surfaceText
                        font.pixelSize: pluginTheme.fontSizeMedium
                        verticalAlignment: TextInput.AlignVCenter
                        selectByMouse: true
                        activeFocusOnTab: true
                        KeyNavigation.backtab: timezoneInput

                        Keys.onReturnPressed: {
                            if (timezoneInput.text.trim() !== "") {
                                addTimezone(timezoneInput.text.trim(), text.trim())
                                timezoneInput.text = ""
                                text = ""
                                timezoneInput.forceActiveFocus()
                            }
                        }
                    }

                    Text {
                        anchors.fill: labelInput
                        anchors.margins: 12
                        text: "e.g., NYC"
                        font.pixelSize: pluginTheme.fontSizeMedium
                        color: pluginTheme.surfaceVariantText
                        verticalAlignment: Text.AlignVCenter
                        visible: labelInput.text.length === 0 && !labelInput.activeFocus
                    }
                }

                Rectangle {
                    width: 50
                    height: 36
                    color: addButtonArea.containsMouse ? pluginTheme.primaryPressed : pluginTheme.primary
                    radius: pluginTheme.cornerRadius
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        anchors.centerIn: parent
                        text: "Add"
                        color: "#FFFFFF"
                        font.pixelSize: pluginTheme.fontSizeSmall
                        font.weight: Font.Medium
                    }

                    MouseArea {
                        id: addButtonArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            console.log("WorldClock: Add button clicked")
                            var timezone = timezoneInput.text.trim()
                            var label = labelInput.text.trim()
                            console.log("WorldClock: Input values - timezone:", timezone, "label:", label)
                            if (timezone !== "") {
                                addTimezone(timezone, label)
                                timezoneInput.text = ""
                                labelInput.text = ""
                                timezoneInput.forceActiveFocus()
                                console.log("WorldClock: Cleared input fields")
                            } else {
                                console.log("WorldClock: No timezone entered")
                            }
                        }
                    }
                }
            }
        }

        Text {
            text: "Current Timezones:"
            font.pixelSize: pluginTheme.fontSizeMedium + 2
            font.weight: Font.Medium
            color: pluginTheme.surfaceText
            visible: timezones.length > 0
        }

        ListView {
            width: parent.width
            height: contentHeight
            model: timezones
            visible: timezones.length > 0
            spacing: 5
            interactive: false

            delegate: Rectangle {
                width: parent.width
                height: 40
                color: "#2A2A2A"
                border.color: "#444444"
                radius: pluginTheme.cornerRadius

                Row {
                    anchors.left: parent.left
                    anchors.leftMargin: pluginTheme.spacingS
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: pluginTheme.spacingS

                    Text {
                        text: modelData.label || modelData.timezone.split('/').pop().replace(/_/g, ' ')
                        color: pluginTheme.surfaceText
                        font.pixelSize: pluginTheme.fontSizeMedium
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: "(" + modelData.timezone + ")"
                        color: pluginTheme.surfaceVariantText
                        font.pixelSize: pluginTheme.fontSizeSmall
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                Rectangle {
                    anchors.right: parent.right
                    anchors.rightMargin: pluginTheme.spacingS
                    anchors.verticalCenter: parent.verticalCenter
                    width: 60
                    height: 28
                    color: removeButtonArea.containsMouse ? "#C42B1C" : "#A4262C"
                    radius: pluginTheme.cornerRadius

                    Text {
                        anchors.centerIn: parent
                        text: "Remove"
                        color: "#FFFFFF"
                        font.pixelSize: pluginTheme.fontSizeSmall
                        font.weight: Font.Medium
                    }

                    MouseArea {
                        id: removeButtonArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            removeTimezone(modelData.timezone)
                        }
                    }
                }
            }
        }

        Text {
            text: "No timezones added yet. Add some timezones above to get started."
            color: pluginTheme.surfaceVariantText
            font.pixelSize: pluginTheme.fontSizeMedium
            visible: timezones.length === 0
        }

        Text {
            text: "Common timezone examples:\n• America/New_York\n• Europe/London\n• Asia/Tokyo\n• Australia/Sydney\n• America/Los_Angeles"
            color: "#AAAAAA"
            font.pixelSize: pluginTheme.fontSizeSmall
            wrapMode: Text.WordWrap
            width: parent.width
        }
    }

    function addTimezone(timezone, label) {
        console.log("WorldClock: addTimezone called with", timezone, label)
        // Check if timezone already exists
        var exists = timezones.some(function(tz) { return tz.timezone === timezone })
        if (exists) {
            console.log("WorldClock: Timezone already exists:", timezone)
            return
        }

        // Add new timezone
        var newTimezones = timezones.slice()
        var newTz = {
            timezone: timezone,
            label: label || timezone.split('/').pop().replace(/_/g, ' ')
        }
        newTimezones.push(newTz)
        console.log("WorldClock: Adding timezone:", JSON.stringify(newTz))

        timezones = newTimezones
        console.log("WorldClock: Updated timezones array:", JSON.stringify(timezones))
        saveTimezones()
    }

    function removeTimezone(timezone) {
        var newTimezones = timezones.filter(function(tz) { return tz.timezone !== timezone })
        timezones = newTimezones
        saveTimezones()
    }

    function saveTimezones() {
        console.log("WorldClock: saveTimezones called, pluginService available:", pluginService !== null)
        if (pluginService && pluginService.savePluginData) {
            console.log("WorldClock: Saving timezones:", JSON.stringify(timezones))
            var result = pluginService.savePluginData("worldClock", "timezones", timezones)
            console.log("WorldClock: Save result:", result)
        } else {
            console.error("WorldClock: pluginService not available for saving, pluginService:", pluginService)
        }
    }

    function loadTimezones() {
        console.log("WorldClock: loadTimezones called, pluginService available:", pluginService !== null)
        if (pluginService && pluginService.loadPluginData) {
            var saved = pluginService.loadPluginData("worldClock", "timezones", [])
            console.log("WorldClock: Loaded saved timezones:", JSON.stringify(saved))
            if (saved && Array.isArray(saved) && saved.length > 0) {
                timezones = saved
                console.log("WorldClock: Applied saved timezones:", JSON.stringify(timezones))
                return
            }
        } else {
            console.error("WorldClock: pluginService not available for loading, pluginService:", pluginService)
        }

        // Default timezones
        console.log("WorldClock: Using default timezones")
        timezones = [
            { timezone: "America/New_York", label: "New York" },
            { timezone: "Europe/London", label: "London" },
            { timezone: "Asia/Tokyo", label: "Tokyo" }
        ]
        console.log("WorldClock: Set default timezones:", JSON.stringify(timezones))
    }

    Component.onCompleted: {
        console.log("WorldClock: Component completed, pluginService available:", pluginService !== null)
        // Only load timezones if pluginService is already available
        if (pluginService) {
            loadTimezones()
        }
        // Give initial focus to the first input field
        Qt.callLater(function() {
            timezoneInput.forceActiveFocus()
        })
    }
}
