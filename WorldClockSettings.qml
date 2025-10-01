import QtQuick
import qs.Common
import qs.Widgets
import qs.Modules.Plugins

PluginSettings {
    id: root

    pluginId: "worldClock"

    StyledText {
        width: parent.width
        text: "World Clock Plugin Settings Demo - All Setting Types"
        font.pixelSize: Theme.fontSizeLarge
        font.weight: Font.Bold
        color: Theme.surfaceText
    }

    StringSetting {
        settingKey: "apiKey"
        label: "API Key"
        description: "Your API key for the weather service"
        placeholder: "Enter your API key..."
        defaultValue: ""
    }

    ToggleSetting {
        settingKey: "showSeconds"
        label: "Show Seconds"
        description: "Display seconds in the time format"
        defaultValue: false
    }

    ToggleSetting {
        settingKey: "use24Hour"
        label: "Use 24-Hour Format"
        description: "Show time in 24-hour format instead of AM/PM"
        defaultValue: true
    }

    SelectionSetting {
        settingKey: "updateInterval"
        label: "Update Interval"
        description: "How often to refresh the time display"
        options: [
            {label: "Every Second", value: "1"},
            {label: "Every 5 Seconds", value: "5"},
            {label: "Every 10 Seconds", value: "10"},
            {label: "Every Minute", value: "60"}
        ]
        defaultValue: "1"
    }

    SelectionSetting {
        settingKey: "dateFormat"
        label: "Date Format"
        description: "Choose how dates are displayed"
        options: [
            {label: "MM/DD/YYYY", value: "mdy"},
            {label: "DD/MM/YYYY", value: "dmy"},
            {label: "YYYY-MM-DD", value: "ymd"}
        ]
        defaultValue: "mdy"
    }

    StyledText {
        width: parent.width
        text: "Timezone Configuration"
        font.pixelSize: Theme.fontSizeLarge
        font.weight: Font.Medium
        color: Theme.surfaceText
    }

    StyledText {
        width: parent.width
        text: "Add timezones to display multiple clocks in the bar"
        font.pixelSize: Theme.fontSizeMedium
        color: Theme.surfaceVariantText
        wrapMode: Text.WordWrap
    }

    ListSettingWithInput {
        settingKey: "timezones"
        label: "Timezones"
        description: "Manage your timezone list"
        fields: [
            {id: "timezone", label: "Timezone", placeholder: "e.g., America/New_York", width: 250, required: true},
            {id: "label", label: "Label", placeholder: "e.g., NYC", width: 150}
        ]
    }

    StyledText {
        width: parent.width
        text: "Common timezone examples:\n• America/New_York\n• Europe/London\n• Asia/Tokyo\n• Australia/Sydney\n• America/Los_Angeles"
        color: Theme.surfaceVariantText
        font.pixelSize: Theme.fontSizeSmall
        wrapMode: Text.WordWrap
    }

    StringSetting {
        settingKey: "customFormat"
        label: "Custom Time Format"
        description: "Advanced: Use custom Qt time format string"
        placeholder: "e.g., hh:mm:ss AP"
        defaultValue: "hh:mm AP"
    }

    ToggleSetting {
        settingKey: "compactMode"
        label: "Compact Display"
        description: "Use a more compact layout in the bar"
        defaultValue: false
    }
}
