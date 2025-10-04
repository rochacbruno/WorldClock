import QtQuick
import Quickshell
import qs.Common
import qs.Widgets
import qs.Modules.Plugins
import "timezone-utils.js" as TimezoneUtils

PluginComponent {
    id: root

    property var timezones: []
    property var pluginService: null
    property bool isLoading: true

    function loadTimezones() {
        if (pluginService && pluginService.loadPluginData) {
            const saved = pluginService.loadPluginData("worldClock", "timezones", [])
            timezones = (saved && Array.isArray(saved)) ? saved : []
            isLoading = false
        }
    }

    Component.onCompleted: {
        loadTimezones()
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: loadTimezones()
    }

    SystemClock {
        id: systemClock
        precision: SystemClock.Seconds
    }

    horizontalBarPill: Component {
        Row {
            spacing: Theme.spacingS

            // Loading spinner
            Item {
                width: 16
                height: 16
                anchors.verticalCenter: parent.verticalCenter
                visible: root.isLoading

                Rectangle {
                    id: spinner
                    width: 12
                    height: 12
                    radius: 6
                    color: "transparent"
                    border.width: 2
                    border.color: Theme.surfaceVariantText
                    anchors.centerIn: parent

                    Rectangle {
                        width: 4
                        height: 4
                        radius: 2
                        color: Theme.surfaceVariantText
                        anchors.top: parent.top
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    RotationAnimation {
                        target: spinner
                        from: 0
                        to: 360
                        duration: 1000
                        loops: Animation.Infinite
                        running: root.isLoading
                    }
                }
            }

            Repeater {
                model: root.timezones

                StyledText {
                    text: {
                        if (!systemClock || !systemClock.date) return "..."

                        const label = (modelData && modelData.label) ? modelData.label : modelData.timezone.split('/').pop().replace(/_/g, ' ')
                        let timeString = ""

                        try {
                            if (TimezoneUtils.isMomentAvailable() && modelData && modelData.timezone) {
                                timeString = TimezoneUtils.getTimeInTimezone(modelData.timezone, true)
                            } else {
                                timeString = "ERR"
                            }
                        } catch (e) {
                            timeString = "ERR"
                        }

                        return label + " " + timeString
                    }
                    font.pixelSize: Theme.fontSizeMedium
                    color: Theme.surfaceText
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            StyledText {
                text: "World Clock"
                font.pixelSize: Theme.fontSizeMedium
                color: Theme.surfaceVariantText
                anchors.verticalCenter: parent.verticalCenter
                visible: !root.isLoading && root.timezones.length === 0
            }
        }
    }

    verticalBarPill: Component {
        Column {
            spacing: Theme.spacingXS

            // Loading spinner
            Item {
                width: 16
                height: 16
                anchors.horizontalCenter: parent.horizontalCenter
                visible: root.isLoading

                Rectangle {
                    id: spinnerVertical
                    width: 12
                    height: 12
                    radius: 6
                    color: "transparent"
                    border.width: 2
                    border.color: Theme.surfaceVariantText
                    anchors.centerIn: parent

                    Rectangle {
                        width: 4
                        height: 4
                        radius: 2
                        color: Theme.surfaceVariantText
                        anchors.top: parent.top
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    RotationAnimation {
                        target: spinnerVertical
                        from: 0
                        to: 360
                        duration: 1000
                        loops: Animation.Infinite
                        running: root.isLoading
                    }
                }
            }

            Repeater {
                model: root.timezones

                Column {
                    spacing: 1

                    StyledText {
                        text: (modelData && modelData.label) ? modelData.label : ""
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.surfaceVariantText
                        anchors.horizontalCenter: parent.horizontalCenter
                        visible: text !== ""
                    }

                    StyledText {
                        text: {
                            if (!systemClock || !systemClock.date) return "..."

                            try {
                                if (TimezoneUtils.isMomentAvailable() && modelData && modelData.timezone) {
                                    return TimezoneUtils.getTimeInTimezone(modelData.timezone, true)
                                }
                            } catch (e) {}

                            return "ERR"
                        }
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.surfaceText
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
            }

            StyledText {
                text: "Clock"
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.surfaceVariantText
                anchors.horizontalCenter: parent.horizontalCenter
                visible: !root.isLoading && root.timezones.length === 0
            }
        }
    }

    popoutContent: Component {
        Column {
            spacing: Theme.spacingL

            StyledText {
                text: "World Clock"
                font.pixelSize: Theme.fontSizeXLarge
                font.weight: Font.Bold
                color: Theme.surfaceText
            }

            Column {
                width: parent.width
                spacing: Theme.spacingS

                // Loading spinner
                Item {
                    width: parent.width
                    height: 60
                    visible: root.isLoading

                    Rectangle {
                        id: spinnerPopout
                        width: 24
                        height: 24
                        radius: 12
                        color: "transparent"
                        border.width: 3
                        border.color: Theme.surfaceVariantText
                        anchors.centerIn: parent

                        Rectangle {
                            width: 6
                            height: 6
                            radius: 3
                            color: Theme.surfaceVariantText
                            anchors.top: parent.top
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        RotationAnimation {
                            target: spinnerPopout
                            from: 0
                            to: 360
                            duration: 1000
                            loops: Animation.Infinite
                            running: root.isLoading
                        }
                    }
                }

                Repeater {
                    model: root.timezones

                    StyledRect {
                        width: parent.width
                        height: 60
                        radius: Theme.cornerRadius
                        color: Theme.surfaceContainerHigh
                        border.width: 0

                        Column {
                            anchors.left: parent.left
                            anchors.leftMargin: Theme.spacingL
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: Theme.spacingXS

                            StyledText {
                                text: (modelData && modelData.label) ? modelData.label : modelData.timezone.split('/').pop().replace(/_/g, ' ')
                                color: Theme.surfaceText
                                font.pixelSize: Theme.fontSizeLarge
                                font.weight: Font.Medium
                            }

                            StyledText {
                                text: {
                                    if (!systemClock || !systemClock.date) return "Loading..."

                                    try {
                                        if (TimezoneUtils.isMomentAvailable() && modelData && modelData.timezone) {
                                            return TimezoneUtils.getTimeInTimezone(modelData.timezone, true)
                                        }
                                    } catch (e) {}

                                    return "Error"
                                }
                                color: Theme.surfaceVariantText
                                font.pixelSize: Theme.fontSizeMedium
                            }
                        }
                    }
                }

                StyledText {
                    text: "No timezones configured.\nAdd some in the plugin settings."
                    color: Theme.surfaceVariantText
                    font.pixelSize: Theme.fontSizeMedium
                    visible: !root.isLoading && root.timezones.length === 0
                }
            }
        }
    }

    popoutWidth: 360
    popoutHeight: 400
}
