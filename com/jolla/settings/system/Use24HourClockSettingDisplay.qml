import QtQuick 2.0
import Sailfish.Silica 1.0
import org.nemomobile.configuration 1.0
import org.nemomobile.systemsettings 1.0

TextSwitch {
    property QtObject dateTimeSettings

    automaticCheck: false
    //% "Use 24-hour clock"
    text: qsTrId("settings_datetime-la-24_hour_clock")
    checked: timeFormatConfig.value === "24"

    onClicked: {
        timeFormatConfig.value = (timeFormatConfig.value === "24" ? "12" : "24")
        timeFormatCompatibilityConfig.value = timeFormatConfig.value
        hourModeUpdater.restart()
    }

    // HACK: if clients use formatter which follows gconf value, and WallClock as time source which
    // follows timed configuration changes, the end result is undeterministic if both change
    // at the same time.
    Timer {
        id: hourModeUpdater

        interval: 500
        onTriggered: {
            dateTimeSettings.setHourMode(timeFormatConfig.value === "24" ? DateTimeSettings.TwentyFourHours
                                                                         : DateTimeSettings.TwelveHours)
        }
    }

    ConfigurationValue {
        id: timeFormatConfig
        key: "/sailfish/i18n/lc_timeformat24h"
    }
    ConfigurationValue {
        id: timeFormatCompatibilityConfig
        key: "/meegotouch/i18n/lc_timeformat24h"
    }
}

