import QtQuick
import qs.Common
import qs.Widgets
import qs.Modules.Plugins

PluginSettings {
    id: root

    pluginId: "worldClock"

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
}
