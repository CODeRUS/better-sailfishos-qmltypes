import QtQuick 2.0
import Sailfish.Silica 1.0
import com.jolla.settings.system 1.0
import org.nemomobile.systemsettings 1.0
import Sailfish.Timezone 1.0

ValueButton {
    id: root

    property QtObject dateTimeSettings

    property string _selectedTimezone

    //% "Time zone"
    label: qsTrId("settings_datetime-la-timezone")
    //: %1 will be replaced by localized country and %2 with localized city
    //% "%1, %2"
    value: qsTrId("settings_datetime-la-localized-timezone").arg(localizer.country).arg(localizer.city)
    enabled: !dateTimeSettings.automaticTimezoneUpdate

    onClicked: {
        var timezonePicker = pageStack.push(timezonePickerComponent)
        timezonePicker.statusChanged.connect(function() {
            // Currently qmsystem (used by time settings) changes the date/time synchronously, which
            // causes a pause in the animation if done during a page transition. Wait until the page
            // is popped to avoid this.
            if (timezonePicker.status === PageStatus.Inactive && root._selectedTimezone != "") {
                dateTimeSettings.timezone = root._selectedTimezone
            }
        })
    }

    TimezoneLocalizer {
        id: localizer
        timezone: dateTimeSettings.timezone
    }

    Component {
        id: timezonePickerComponent
        TimezonePicker {
            onTimezoneClicked: {
                root._selectedTimezone = name
                pageStack.pop()
            }
        }
    }
}
