import QtQuick
import qs.Common
import qs.Widgets
import qs.Modules.Plugins
import "timezone-utils.js" as TimezoneUtils

PluginSettings {
    id: root

    pluginId: "worldClock"

    ToggleSetting {
        settingKey: "iconOnly"
        label: "Icon Only"
        description: "Display only a globe icon in the bar (when not cycling)"
        defaultValue: false
    }

    ToggleSetting {
        settingKey: "showAll"
        label: "Show all clocks at once"
        description: "When off, clocks cycle one at a time on the bar"
        defaultValue: true
    }

    SliderSetting {
        settingKey: "cycleInterval"
        label: "Cycle interval (seconds)"
        description: "How often to switch to the next clock (when cycling)"
        minimum: 3
        maximum: 120
        defaultValue: 15
    }

    ToggleSetting {
        settingKey: "use24h"
        label: "Use 24-hour format"
        description: "Display time in 24-hour format (e.g. 14:30 instead of 2:30 PM)"
        defaultValue: true
    }

    ListSettingWithInput {
        settingKey: "timezones"
        label: "Timezones"
        description: "Add timezones to display. Use standard tz names like Europe/Berlin, America/New_York, Asia/Tokyo."
        fields: [
            {id: "timezone", label: "Timezone", placeholder: "e.g., America/New_York", width: 260, required: true},
            {id: "label", label: "Label", placeholder: "e.g., NYC", width: 140}
        ]
    }

    Column {
        width: parent.width
        spacing: Theme.spacingS

        StyledText {
            width: parent.width
            text: "Common timezones:"
            color: Theme.surfaceText
            font.pixelSize: Theme.fontSizeSmall
            font.weight: Font.Medium
        }

        StyledText {
            width: parent.width
            text: TimezoneUtils.getCommonTimezones().slice(0, 30).map(function(tz) {
                return "\u2022 " + tz;
            }).join("\n")
            color: Theme.surfaceVariantText
            font.pixelSize: Theme.fontSizeSmall
            wrapMode: Text.WordWrap
        }

        StyledText {
            width: parent.width
            text: "Run 'timedatectl list-timezones' in a terminal for the full list."
            color: Theme.surfaceVariantText
            font.pixelSize: Theme.fontSizeSmall
            font.italic: true
            wrapMode: Text.WordWrap
        }
    }
}
