# WorldClock Plugin for DMS

A plugin that displays multiple timezones in the DMS bar.

<img alt="WorldClock plugin" src="screenshot.png" />



## Installation

```bash
mkdir -p ~/.config/DankMaterialShell/plugins/
git clone https://github.com/rochacbruno/WorldClock ~/.config/DankMaterialShell/plugins/WorldClock
```

## Usage

1. Open DMS Settings <kbd>Super + , </kbd>
2. Go to the "Plugins" tab
3. Enable the "World Clock" plugin
4. Configure timezones in the plugin settings
5. Add the "worldClock" widget to your DankBar configuration

## Configuration

The plugin stores timezone configurations in the DMS settings. You can add/remove timezones through the plugin settings interface.

### Common Timezone Examples:
- America/New_York (Eastern Time)
- America/Los_Angeles (Pacific Time)
- Europe/London (Greenwich Mean Time)
- Europe/Paris (Central European Time)
- Asia/Tokyo (Japan Standard Time)
- Australia/Sydney (Australian Eastern Time)

## Files

- `plugin.json` - Plugin manifest and metadata
- `WorldClockWidget.qml` - Main widget component
- `WorldClockSettings.qml` - Settings interface
- `timezone-utils.js` - Timezone utility functions
- `moment.js` - Moment.js library (stub - replace with real file)
- `moment-timezone.js` - Moment timezone library (stub - replace with real file)

## Permissions

This plugin requires:
- `settings_read` - To read timezone configurations
- `settings_write` - To save timezone configurations


<img width="792" height="786" alt="Screenshot from 2025-09-30 19-34-34" src="https://github.com/user-attachments/assets/98e03d98-2752-41cf-9678-419a11560031" />
<img width="490" height="574" alt="Screenshot from 2025-09-30 19-34-51" src="https://github.com/user-attachments/assets/87d7b179-8ed5-4ef4-9de1-de27137c8544" />
