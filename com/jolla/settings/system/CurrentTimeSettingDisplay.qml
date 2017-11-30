import QtQuick 2.0
import Sailfish.Silica 1.0
import com.jolla.settings.system 1.0
import org.nemomobile.systemsettings 1.0
import org.nemomobile.time 1.0

ValueButton {
    id: root

    property QtObject dateTimeSettings

    //% "Time"
    label: qsTrId("settings_datetime-la-time")
    enabled: !dateTimeSettings.automaticTimeUpdate
    value: Format.formatDate(wallClock.time, Formatter.TimeValue)

    onClicked: {
        var date = new Date()
        var dialog = pageStack.push("Sailfish.Silica.TimePickerDialog", {
            hour: date.getHours(),
            minute: date.getMinutes()
        })
        dialog.statusChanged.connect(function() {
            // Currently qmsystem (used by time settings) changes the date/time synchronously, which
            // causes a pause in the animation if done during a page transition. Wait until the page
            // is popped to avoid this.
            if (dialog.status === PageStatus.Inactive && dialog.result === DialogResult.Accepted) {
                dateTimeSettings.setTime(dialog.hour, dialog.minute)
            }
        })
    }

    WallClock {
        id: wallClock
        enabled: Qt.application.active
        updateFrequency: WallClock.Minute
    }
}
