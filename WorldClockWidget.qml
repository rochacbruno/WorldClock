import QtQuick
import Quickshell
import "timezone-utils.js" as TimezoneUtils

Rectangle {
    id: root

    property bool compactMode: false
    property string section: "center"
    property var popupTarget: null
    property var parentScreen: null
    property real barHeight: 48
    property real widgetHeight: 30
    property var timezones: []
    property var pluginService: null

    function loadTimezones() {
        console.log("WorldClockWidget: loadTimezones called, pluginService available:", pluginService !== null)
        if (pluginService && pluginService.loadPluginData) {
            var saved = pluginService.loadPluginData("worldClock", "timezones", [])
            console.log("WorldClockWidget: Loaded saved timezones:", JSON.stringify(saved))
            if (saved && Array.isArray(saved) && saved.length > 0) {
                timezones = saved
                console.log("WorldClockWidget: Applied saved timezones:", JSON.stringify(timezones))
                return
            }
        } else {
            console.log("WorldClockWidget: PluginService not available, using fallback method")
            // Fallback: try global PluginService access
            if (typeof PluginService !== "undefined" && PluginService.loadPluginData) {
                var saved = PluginService.loadPluginData("worldClock", "timezones", [])
                console.log("WorldClockWidget: Loaded saved timezones via global access:", JSON.stringify(saved))
                if (saved && Array.isArray(saved) && saved.length > 0) {
                    timezones = saved
                    console.log("WorldClockWidget: Applied saved timezones via global access:", JSON.stringify(timezones))
                    return
                }
            }
        }

        // Default timezones
        console.log("WorldClockWidget: Using default timezones")
        timezones = [
            { timezone: "America/New_York", label: "New York" },
            { timezone: "Europe/London", label: "London" },
            { timezone: "Asia/Tokyo", label: "Tokyo" }
        ]
    }
    readonly property real horizontalPadding: 8

    signal worldClockClicked

    width: clockRow.implicitWidth + horizontalPadding * 2
    height: widgetHeight
    radius: 8
    color: {
        var baseColor = clockMouseArea.containsMouse ? "#40FFFFFF" : "#20FFFFFF"
        return baseColor
    }

    Row {
        id: clockRow

        anchors.centerIn: parent
        spacing: 8 // Default spacing

        Repeater {
            model: root.timezones

            Text {
                text: {
                    if (!systemClock || !systemClock.date) return "Loading..."

                    var label = (modelData && modelData.label) ? modelData.label : ""
                    if (!label || (modelData && label === modelData.timezone)) {
                        if (modelData && modelData.timezone) {
                            label = modelData.timezone.split('/').pop().replace(/_/g, ' ')
                        }
                    }

                    var timeString = ""
                    try {
                        if (TimezoneUtils.isMomentAvailable() && modelData && modelData.timezone) {
                            timeString = TimezoneUtils.getTimeInTimezone(modelData.timezone, true) // use24Hour = true
                        } else {
                            timeString = "missing moment.js dependency"
                        }
                    } catch (e) {
                        timeString = "missing moment.js dependency"
                    }

                    return label + " - " + timeString
                }
                font.pixelSize: 13
                color: "#FFFFFF"
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        Text {
            text: "World Clock (Add timezones in settings)"
            font.pixelSize: 13
            color: "#CCCCCC"
            anchors.verticalCenter: parent.verticalCenter
            visible: root.timezones.length === 0
        }
    }

    SystemClock {
        id: systemClock
        precision: SystemClock.Seconds
    }

    MouseArea {
        id: clockMouseArea

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onPressed: {
            if (popupTarget && popupTarget.setTriggerPosition) {
                var globalPos = mapToGlobal(0, 0)
                var currentScreen = parentScreen || Screen
                var screenX = currentScreen.x || 0
                var relativeX = globalPos.x - screenX
                popupTarget.setTriggerPosition(relativeX, 100, width, section, currentScreen) // Default popup position
            }
            root.worldClockClicked()
        }
    }

    Component.onCompleted: {
        loadTimezones()
    }

    // Refresh timezones periodically to pick up settings changes
    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: loadTimezones()
    }
}