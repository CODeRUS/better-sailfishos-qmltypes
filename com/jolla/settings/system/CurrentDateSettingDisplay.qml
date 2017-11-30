import QtQuick 2.0
import Sailfish.Silica 1.0
import com.jolla.settings.system 1.0
import org.nemomobile.systemsettings 1.0
import org.nemomobile.time 1.0

ValueButton {
    id: root

    property QtObject dateTimeSettings
    property date defaultDate: wallClock.time

    //% "Date"
    label: qsTrId("settings_datetime-la-date")
    enabled: !dateTimeSettings.automaticTimeUpdate
    value: Format.formatDate(wallClock.time, Format.DateLong)

    onClicked: {
        var dialog = pageStack.push("Sailfish.Silica.DatePickerDialog", { "date": root.defaultDate })
        dialog.date = Qt.binding(function() { return root.defaultDate })
        dialog.statusChanged.connect(function() {
            // Currently qmsystem (used by time settings) changes the date/time synchronously, which
            // causes a pause in the animation if done during a page transition. Wait until the page
            // is popped to avoid this.
            if (dialog.status === PageStatus.Inactive && dialog.result === DialogResult.Accepted) {
                dateTimeSettings.setDate(dialog.date)
            }
        })
    }

    WallClock {
        id: wallClock
        updateFrequency: WallClock.Day
    }
}
