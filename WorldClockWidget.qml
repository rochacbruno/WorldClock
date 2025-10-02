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

    function loadTimezones() {
        if (pluginService && pluginService.loadPluginData) {
            const saved = pluginService.loadPluginData("worldClock", "timezones", [])
            if (saved && Array.isArray(saved) && saved.length > 0) {
                timezones = saved
                return
            }
        }

        timezones = [
            { timezone: "America/New_York", label: "NYC" },
            { timezone: "Europe/London", label: "London" },
            { timezone: "Asia/Tokyo", label: "Tokyo" }
        ]
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
                visible: root.timezones.length === 0
            }
        }
    }

    verticalBarPill: Component {
        Column {
            spacing: Theme.spacingXS

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
                visible: root.timezones.length === 0
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
                    visible: root.timezones.length === 0
                }
            }
        }
    }

    popoutWidth: 360
    popoutHeight: 400
}
