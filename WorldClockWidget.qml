import QtQuick
import Quickshell
import qs.Common
import qs.Widgets
import qs.Modules.Plugins
import "timezone-utils.js" as TimezoneUtils

PluginComponent {
    id: root

    // ── Persisted settings ──────────────────────────────────────────
    property var timezones: []
    property var pluginService: null
    property bool isLoading: true
    property bool iconOnly: false
    property bool showAll: true
    property int cycleInterval: 15
    property bool use24h: true

    // ── Runtime state ───────────────────────────────────────────────
    property int currentIndex: 0

    function loadTimezones() {
        if (pluginService && pluginService.loadPluginData) {
            var saved = pluginService.loadPluginData("worldClock", "timezones", [])
            timezones = (saved && Array.isArray(saved)) ? saved : []

            iconOnly = pluginService.loadPluginData("worldClock", "iconOnly", false) === true
            showAll = pluginService.loadPluginData("worldClock", "showAll", true) !== false
            cycleInterval = pluginService.loadPluginData("worldClock", "cycleInterval", 15) || 15
            use24h = pluginService.loadPluginData("worldClock", "use24h", true) !== false

            var savedIdx = pluginService.loadPluginState
                ? pluginService.loadPluginState("worldClock", "currentIndex", 0)
                : 0
            var barCount = barTimezones().length
            currentIndex = (savedIdx >= 0 && barCount > 0 && savedIdx < barCount) ? savedIdx : 0

            isLoading = false
        }
    }

    Component.onCompleted: {
        loadTimezones()
    }

    // Re-read settings periodically so the bar picks up changes
    Timer {
        interval: 3000
        running: true
        repeat: true
        onTriggered: loadTimezones()
    }

    SystemClock {
        id: systemClock
        precision: SystemClock.Seconds
    }

    // ── Cycle timer (only active in cycling mode) ──────────────────
    Timer {
        id: cycleTimer
        interval: root.cycleInterval * 1000
        running: !root.showAll && root.barTimezones().length > 1
        repeat: true
        onTriggered: {
            var barCount = root.barTimezones().length
            if (barCount > 0) {
                root.currentIndex = (root.currentIndex + 1) % barCount
            }
            if (root.pluginService && root.pluginService.savePluginState) {
                root.pluginService.savePluginState("worldClock", "currentIndex", root.currentIndex)
            }
        }
    }

    // ── Helpers ─────────────────────────────────────────────────────
    function labelFor(entry) {
        return (entry && entry.label) ? entry.label : TimezoneUtils.cityFromTz(entry.timezone)
    }

    function formatTime(tz) {
        if (!systemClock || !systemClock.date) return "..."
        try {
            if (TimezoneUtils.isMomentAvailable() && tz) {
                return TimezoneUtils.getTimeInTimezone(tz, root.use24h)
            }
        } catch (e) {}
        return "ERR"
    }

    function dayOffsetText(tz) {
        if (!systemClock || !systemClock.date) return ""
        var offset = TimezoneUtils.getDayOffset(tz)
        if (offset > 0) return " +" + offset
        if (offset < 0) return " " + offset
        return ""
    }

    function entryText(entry) {
        return labelFor(entry) + " " + formatTime(entry.timezone) + dayOffsetText(entry.timezone)
    }

    // Timezones filtered to only those visible on the bar
    function barTimezones() {
        return timezones.filter(function(entry) { return entry.showOnBar !== false; })
    }

    // Model for the bar: either all bar-visible timezones or just the current one
    function visibleModel() {
        var bar = barTimezones()
        if (bar.length === 0) return []
        if (showAll) return bar
        var idx = Math.min(currentIndex, bar.length - 1)
        return [bar[idx]]
    }

    // Toggle showOnBar for a timezone and persist
    function toggleShowOnBar(index) {
        var updated = timezones.slice()
        var entry = Object.assign({}, updated[index])
        entry.showOnBar = (entry.showOnBar === false) ? true : false
        updated[index] = entry
        timezones = updated
        if (pluginService && pluginService.savePluginData) {
            pluginService.savePluginData("worldClock", "timezones", updated)
        }
    }

    // Move a timezone from one index to another and persist
    function moveTimezone(fromIndex, toIndex) {
        if (toIndex < 0 || toIndex >= timezones.length) return
        var updated = timezones.slice()
        var item = updated.splice(fromIndex, 1)[0]
        updated.splice(toIndex, 0, item)
        timezones = updated
        if (pluginService && pluginService.savePluginData) {
            pluginService.savePluginData("worldClock", "timezones", updated)
        }
    }

    function addTimezone(timezone, label) {
        var tz = timezone.trim()
        if (!tz) return false
        if (!TimezoneUtils.isValidTimezone(tz)) return false
        for (var i = 0; i < timezones.length; i++) {
            if (timezones[i].timezone === tz) return false
        }
        var entry = { timezone: tz, showOnBar: true }
        if (label && label.trim()) entry.label = label.trim()
        var updated = timezones.slice()
        updated.push(entry)
        timezones = updated
        if (pluginService && pluginService.savePluginData) {
            pluginService.savePluginData("worldClock", "timezones", updated)
        }
        return true
    }

    function removeTimezone(index) {
        if (index < 0 || index >= timezones.length) return
        var updated = timezones.slice()
        updated.splice(index, 1)
        timezones = updated
        if (pluginService && pluginService.savePluginData) {
            pluginService.savePluginData("worldClock", "timezones", updated)
        }
    }

    // ── Horizontal bar pill ─────────────────────────────────────────
    horizontalBarPill: Component {
        Row {
            spacing: Theme.spacingS

            // Icon-only mode: globe when showAll, cycling text when !showAll
            StyledText {
                text: "\u{1F310}\uFE0E"
                font.pixelSize: Theme.fontSizeLarge
                color: Theme.surfaceText
                anchors.verticalCenter: parent.verticalCenter
                visible: root.iconOnly && root.showAll
            }

            // Loading spinner
            Item {
                width: 16
                height: 16
                anchors.verticalCenter: parent.verticalCenter
                visible: root.isLoading && !root.iconOnly

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

            // Icon-only cycling mode: show one timezone at a time
            Repeater {
                model: (root.iconOnly && !root.showAll) ? root.visibleModel() : []

                StyledText {
                    text: root.entryText(modelData)
                    font.pixelSize: Theme.fontSizeMedium
                    color: Theme.surfaceText
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            // Normal mode: show visible timezones with dot separators
            Repeater {
                model: root.iconOnly ? [] : root.visibleModel()

                Row {
                    spacing: Theme.spacingXS
                    anchors.verticalCenter: parent.verticalCenter

                    StyledText {
                        text: "\u00B7"
                        font.pixelSize: Theme.fontSizeMedium
                        color: Theme.withAlpha(Theme.surfaceText, 0.4)
                        visible: index > 0
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    StyledText {
                        text: root.entryText(modelData)
                        font.pixelSize: Theme.fontSizeMedium
                        color: Theme.surfaceText
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }

            StyledText {
                text: "World Clock"
                font.pixelSize: Theme.fontSizeMedium
                color: Theme.surfaceVariantText
                anchors.verticalCenter: parent.verticalCenter
                visible: !root.isLoading && root.timezones.length === 0 && !root.iconOnly
            }
        }
    }

    // ── Vertical bar pill ───────────────────────────────────────────
    verticalBarPill: Component {
        Column {
            spacing: Theme.spacingXS

            // Icon-only mode: globe when showAll
            StyledText {
                text: "\u{1F310}\uFE0E"
                font.pixelSize: Theme.fontSizeLarge
                color: Theme.surfaceText
                anchors.horizontalCenter: parent.horizontalCenter
                visible: root.iconOnly && root.showAll
            }

            // Icon-only cycling mode: show one timezone at a time
            Repeater {
                model: (root.iconOnly && !root.showAll) ? root.visibleModel() : []

                Column {
                    spacing: 1
                    anchors.horizontalCenter: parent.horizontalCenter

                    StyledText {
                        text: root.labelFor(modelData)
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.surfaceVariantText
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    StyledText {
                        text: root.formatTime(modelData.timezone) + root.dayOffsetText(modelData.timezone)
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.surfaceText
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
            }

            // Normal mode
            Repeater {
                model: root.iconOnly ? [] : root.visibleModel()

                Column {
                    spacing: 1
                    anchors.horizontalCenter: parent.horizontalCenter

                    StyledText {
                        text: root.labelFor(modelData)
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.surfaceVariantText
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    StyledText {
                        text: root.formatTime(modelData.timezone) + root.dayOffsetText(modelData.timezone)
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
                visible: !root.isLoading && root.timezones.length === 0 && !root.iconOnly
            }
        }
    }

    // ── Popout panel (click to expand) ──────────────────────────────
    popoutContent: Component {
        Column {
            spacing: Theme.spacingL

            StyledText {
                text: "World Clock"
                font.pixelSize: Theme.fontSizeXLarge
                font.weight: Font.Bold
                color: Theme.surfaceText
            }

            // Display mode indicator
            StyledText {
                text: root.showAll
                    ? "Showing all clocks"
                    : "Cycling every " + root.cycleInterval + "s"
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.surfaceVariantText
            }

            // Add timezone inputs
            Column {
                width: parent.width
                spacing: Theme.spacingXS

                Row {
                    width: parent.width
                    spacing: Theme.spacingXS

                    Rectangle {
                        width: parent.width * 0.55 - Theme.spacingXS
                        height: addTzInput.height
                        color: Qt.rgba(Theme.surfaceVariantText.r, Theme.surfaceVariantText.g, Theme.surfaceVariantText.b, 0.15)
                        radius: Theme.cornerRadius
                        border.width: addTzError.visible ? 1 : 0
                        border.color: Theme.withAlpha("red", 0.6)

                        TextInput {
                            id: addTzInput
                            width: parent.width - Theme.spacingS * 2
                            anchors.centerIn: parent
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceText
                            padding: Theme.spacingXS
                            clip: true
                            activeFocusOnTab: true
                            KeyNavigation.tab: addTzLabelInput

                            property string placeholderText: "America/New_York"

                            Text {
                                text: addTzInput.placeholderText
                                font.pixelSize: addTzInput.font.pixelSize
                                color: Theme.surfaceVariantText
                                visible: !addTzInput.text && !addTzInput.activeFocus
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Keys.onReturnPressed: addTzButton.doAdd()
                            onTextChanged: if (addTzError.visible) addTzError.visible = false
                        }
                    }

                    Rectangle {
                        width: parent.width * 0.25 - Theme.spacingXS
                        height: addTzLabelInput.height
                        color: Qt.rgba(Theme.surfaceVariantText.r, Theme.surfaceVariantText.g, Theme.surfaceVariantText.b, 0.15)
                        radius: Theme.cornerRadius

                        TextInput {
                            id: addTzLabelInput
                            width: parent.width - Theme.spacingS * 2
                            anchors.centerIn: parent
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceText
                            padding: Theme.spacingXS
                            clip: true
                            activeFocusOnTab: true
                            KeyNavigation.tab: addTzInput

                            property string placeholderText: "Label"

                            Text {
                                text: addTzLabelInput.placeholderText
                                font.pixelSize: addTzLabelInput.font.pixelSize
                                color: Theme.surfaceVariantText
                                visible: !addTzLabelInput.text && !addTzLabelInput.activeFocus
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Keys.onReturnPressed: addTzButton.doAdd()
                        }
                    }

                    DankActionButton {
                        id: addTzButton
                        buttonSize: 28
                        iconName: "add"
                        iconColor: Theme.primary
                        anchors.verticalCenter: parent.verticalCenter

                        function doAdd() {
                            if (addTzInput.text.trim() === "") return
                            var ok = root.addTimezone(addTzInput.text, addTzLabelInput.text)
                            if (ok) {
                                addTzInput.text = ""
                                addTzLabelInput.text = ""
                                addTzError.visible = false
                            } else {
                                addTzError.visible = true
                            }
                        }

                        onClicked: doAdd()
                    }
                }

                StyledText {
                    id: addTzError
                    text: "Invalid or duplicate timezone"
                    color: "red"
                    font.pixelSize: Theme.fontSizeSmall
                    visible: false
                }
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
                        height: 64
                        radius: Theme.cornerRadius
                        color: (root.currentIndex === index && !root.showAll)
                            ? Theme.withAlpha(Theme.primary, 0.15)
                            : Theme.surfaceContainerHigh
                        border.width: 0

                        Column {
                            anchors.left: parent.left
                            anchors.leftMargin: Theme.spacingL
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: Theme.spacingXS

                            StyledText {
                                text: root.labelFor(modelData)
                                color: Theme.surfaceText
                                font.pixelSize: Theme.fontSizeLarge
                                font.weight: Font.Medium
                            }

                            StyledText {
                                text: modelData.timezone
                                color: Theme.surfaceVariantText
                                font.pixelSize: Theme.fontSizeSmall
                            }
                        }

                        Row {
                            anchors.right: parent.right
                            anchors.rightMargin: Theme.spacingL
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: Theme.spacingS

                            DankActionButton {
                                buttonSize: 24
                                iconName: "arrow_upward"
                                iconColor: Theme.surfaceVariantText
                                visible: index > 0
                                anchors.verticalCenter: parent.verticalCenter
                                onClicked: root.moveTimezone(index, index - 1)
                            }

                            DankActionButton {
                                buttonSize: 24
                                iconName: "arrow_downward"
                                iconColor: Theme.surfaceVariantText
                                visible: index < root.timezones.length - 1
                                anchors.verticalCenter: parent.verticalCenter
                                onClicked: root.moveTimezone(index, index + 1)
                            }

                            DankActionButton {
                                buttonSize: 28
                                iconName: (modelData.showOnBar !== false) ? "visibility" : "visibility_off"
                                iconColor: (modelData.showOnBar !== false) ? Theme.primary : Theme.outline
                                anchors.verticalCenter: parent.verticalCenter
                                onClicked: root.toggleShowOnBar(index)
                            }

                            DankActionButton {
                                buttonSize: 24
                                iconName: "delete"
                                iconColor: Theme.outline
                                anchors.verticalCenter: parent.verticalCenter
                                onClicked: root.removeTimezone(index)
                            }

                            StyledText {
                                text: root.formatTime(modelData.timezone)
                                color: Theme.primary
                                font.pixelSize: Theme.fontSizeXLarge
                                font.weight: Font.Bold
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            StyledText {
                                text: root.dayOffsetText(modelData.timezone)
                                color: Theme.surfaceVariantText
                                font.pixelSize: Theme.fontSizeSmall
                                anchors.verticalCenter: parent.verticalCenter
                                visible: text !== ""
                            }
                        }
                    }
                }

                StyledText {
                    text: "No timezones configured.\nAdd one above."
                    color: Theme.surfaceVariantText
                    font.pixelSize: Theme.fontSizeMedium
                    visible: !root.isLoading && root.timezones.length === 0
                }
            }
        }
    }

    popoutWidth: 400
    popoutHeight: 480
}
