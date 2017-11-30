/****************************************************************************
**
** Copyright (C) 2013 Jolla Ltd.
** Contact: Petri M. Gerdt <petri.gerdt@jollamobile.com>
**
****************************************************************************/

import QtQuick 2.0
import Sailfish.Silica 1.0
import org.nemomobile.time 1.0
import org.nemomobile.configuration 1.0


Text {
    id: timeText

    property alias time: wallClock.time
    property bool updatesEnabled

    function forceUpdate() {
        wallClock.allowEnabled = false
        wallClock.allowEnabled = true
    }

    // Glyphs larger than 100 or so look poorly in the default rendering mode
    renderType: font.pixelSize > 100 ? Text.NativeRendering : Text.QtRendering

    font { pixelSize: Theme.fontSizeHuge * 1.5; family: Theme.fontFamilyHeading }
    text: {
        if (timeFormatConfig.value === "24") {
            return Format.formatDate(time, Format.TimeValueTwentyFourHours)
        } else {
            // this is retarded, yay for qt and js time formatting options
            var hours = time.getHours()
            if (hours === 0) {
                hours = 12
            } else if (hours > 12) {
                hours -= 12
            }

            //: Pattern for 12h time, h, hh, m, mm are supported, everything else left as is. escaping with ' not supported
            //% "h:mm"
            var result = qsTrId("lipstick-jolla-home-12h_time_pattern_without_ap")
            var zero = 0

            if (result.indexOf("hh") !== -1) {
                var hourString = ""

                if (hours < 10) {
                    hourString = zero.toLocaleString()
                }
                hourString += hours.toLocaleString()

                result = result.replace("hh", hourString)
            } else {
                result = result.replace("h", hours.toLocaleString())
            }

            var minutes = time.getMinutes()
            if (result.indexOf("mm") !== -1) {
                var minuteString = ""
                if (minutes < 10) {
                    minuteString = zero.toLocaleString()
                }
                minuteString += minutes.toLocaleString()

                result = result.replace("mm", minuteString)
            } else {
                result = result.replace("m", minutes.toLocaleString())
            }

            return result
        }
    }

    ConfigurationValue {
        id: timeFormatConfig
        key: "/sailfish/i18n/lc_timeformat24h"
    }

    WallClock {
        id: wallClock
        property bool allowEnabled: true
        enabled: allowEnabled && timeText.updatesEnabled
        updateFrequency: WallClock.Minute
    }


}
