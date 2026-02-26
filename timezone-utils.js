// Import moment.js and moment-timezone from the same plugin directory
.import "moment.js" as MomentJS
.import "moment-timezone.js" as MomentTimezone

function getTimeInTimezone(timezone, use24Hour) {
    try {
        // Check if moment is available in global scope
        if (typeof moment !== 'undefined') {
            const format = use24Hour ? "HH:mm" : "h:mm A"
            return moment().tz(timezone).format(format)
        } else {
            return "moment.js not available"
        }
    } catch (e) {
        return "invalid timezone"
    }
}

function isMomentAvailable() {
    return typeof moment !== 'undefined'
}

function cityFromTz(tz) {
    return tz.split('/').pop().replace(/_/g, ' ');
}

var commonTimezones = [
    "Africa/Cairo",
    "Africa/Johannesburg",
    "Africa/Lagos",
    "Africa/Nairobi",
    "America/Anchorage",
    "America/Argentina/Buenos_Aires",
    "America/Bogota",
    "America/Chicago",
    "America/Denver",
    "America/Halifax",
    "America/Los_Angeles",
    "America/Mexico_City",
    "America/New_York",
    "America/Phoenix",
    "America/Santiago",
    "America/Sao_Paulo",
    "America/Toronto",
    "America/Vancouver",
    "Asia/Bangkok",
    "Asia/Colombo",
    "Asia/Dubai",
    "Asia/Hong_Kong",
    "Asia/Istanbul",
    "Asia/Jakarta",
    "Asia/Karachi",
    "Asia/Kolkata",
    "Asia/Kuala_Lumpur",
    "Asia/Manila",
    "Asia/Seoul",
    "Asia/Shanghai",
    "Asia/Singapore",
    "Asia/Taipei",
    "Asia/Tehran",
    "Asia/Tokyo",
    "Atlantic/Reykjavik",
    "Australia/Melbourne",
    "Australia/Perth",
    "Australia/Sydney",
    "Europe/Amsterdam",
    "Europe/Athens",
    "Europe/Berlin",
    "Europe/Brussels",
    "Europe/Bucharest",
    "Europe/Budapest",
    "Europe/Copenhagen",
    "Europe/Dublin",
    "Europe/Helsinki",
    "Europe/Kyiv",
    "Europe/Lisbon",
    "Europe/London",
    "Europe/Madrid",
    "Europe/Moscow",
    "Europe/Oslo",
    "Europe/Paris",
    "Europe/Prague",
    "Europe/Rome",
    "Europe/Stockholm",
    "Europe/Vienna",
    "Europe/Warsaw",
    "Europe/Zurich",
    "Pacific/Auckland",
    "Pacific/Fiji",
    "Pacific/Honolulu",
    "US/Eastern",
    "US/Central",
    "US/Mountain",
    "US/Pacific",
    "UTC"
];

function getCommonTimezones() {
    return commonTimezones;
}