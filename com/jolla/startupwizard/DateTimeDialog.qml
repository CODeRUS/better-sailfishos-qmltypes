import QtQuick 2.0
import Sailfish.Silica 1.0
import org.nemomobile.systemsettings 1.0
import org.nemomobile.configuration 1.0
import com.jolla.settings.system 1.0

StandardWizardDialog {
    id: root

    property string _dateString

    function _reloadDateString() {
        _dateString = Format.formatDate(new Date(), Format.DateFull)
    }

    //% "Date and time"
    heading: qsTrId("startupwizard-he-time_and_date")

    //: Current time and date. %1=date, %2=time
    //% "%1 at %2"
    description: qsTrId("startupwizard-la-current_time_and_date").arg(_dateString).arg(timeSettingDisplay.value)

    Component.onCompleted: {
        if (timeFormatConfig.value == undefined) {
            // If time format has never been set, default to 24hr.
            timeFormatConfig.value = "24"
        }

        _reloadDateString()
    }

    onStatusChanged: {
        if (status == PageStatus.Deactivating) {
            // ensure the bottom section does not jump around when swiping back from the
            // TimezonePicker if it still has the vkb open
            bottomDetails.y = root.height - bottomDetails.height - Theme.paddingLarge
            bottomDetails.anchors.bottom = undefined
        }
    }

    Column {
        id: bottomDetails
        width: parent.width
        anchors {
            bottom: parent.bottom
            bottomMargin: Theme.paddingLarge
        }

        Label {
            //: Heading above buttons that allow current time and date settings to be changed
            //% "Not quite right? Change here"
            text: qsTrId("startupwizard-he-change_time_and_date")
            x: Theme.paddingLarge
            width: parent.width - x*2
            wrapMode: Text.Wrap
            height: Theme.itemSizeSmall
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: Theme.fontSizeExtraSmall
            color: Theme.rgba(Theme.highlightColor, 0.9)
        }

        CurrentDateSettingDisplay {
            id: dateSettingDisplay
            property date noDate
            dateTimeSettings: dateTimeSettings
            enabled: true
            defaultDate: noDate
        }

        CurrentTimeSettingDisplay {
            id: timeSettingDisplay
            dateTimeSettings: dateTimeSettings
            enabled: true
        }

        CurrentTimeZoneSettingDisplay {
            dateTimeSettings: dateTimeSettings
            enabled: true
        }

        Use24HourClockSettingDisplay {
            dateTimeSettings: dateTimeSettings
        }
    }

    DateTimeSettings {
        id: dateTimeSettings

        onTimeChanged: {
            root._reloadDateString()
        }
    }

    ConfigurationValue {
        id: timeFormatConfig
        key: "/sailfish/i18n/lc_timeformat24h"
    }
}
