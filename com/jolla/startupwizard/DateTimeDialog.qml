import QtQuick 2.0
import Sailfish.Silica 1.0
import com.jolla.startupwizard 1.0
import org.nemomobile.systemsettings 1.0
import org.nemomobile.configuration 1.0
import com.jolla.settings.system 1.0

Dialog {
    id: root

    property string _dateString

    function _reloadDateString() {
        _dateString = Format.formatDate(new Date(), Format.DateFull)
    }

    Component.onCompleted: {
        if (timeFormatConfig.value == undefined) {
            var timeFormat = Qt.locale().timeFormat(Locale.ShortFormat)
            var twelveHourClock = timeFormat.indexOf("ap") >= 0 || timeFormat.indexOf("AP") >= 0

            if (twelveHourClock) {
                timeFormatConfig.value = "12"
                dateTimeSettings.setHourMode(DateTimeSettings.TwelveHours)
            } else {
                timeFormatConfig.value = "24"
                dateTimeSettings.setHourMode(DateTimeSettings.TwentyFourHours)
            }
        }
        _reloadDateString()

        if (dateTimeSettings.automaticTimeUpdate) {
            //: Current time and date. %1=date, %2=time
            //% "%1 at %2"
            header.title = qsTrId("startupwizard-la-current_time_and_date").arg(_dateString).arg(timeSettingDisplay.value)

            //: Displayed when date and time are automatically retrieved from internet
            //% "The date and time were automatically retrieved. If these are not correct, please change them below."
            descriptionLabel.text = qsTrId("startupwizard-la-time_and_date_auto_retrieved")
        } else {
            //% "Please select your date and time"
            header.title = qsTrId("startupwizard-la-select_time_and_date")
        }
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: contentColumn.height

        Column {
            id: contentColumn
            width: parent.width

            WizardDialogHeader {
                id: header
                dialog: root
            }

            Label {
                id: descriptionLabel
                x: Theme.horizontalPageMargin
                width: parent.width - x*2
                height: implicitHeight + Theme.paddingLarge*2
                verticalAlignment: Text.AlignVCenter
                visible: text != ""
                wrapMode: Text.WordWrap
                font.pixelSize: Theme.fontSizeExtraSmall
                color: Theme.highlightColor
            }

            CurrentTimeZoneSettingDisplay {
                dateTimeSettings: dateTimeSettings
                enabled: true
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

            Use24HourClockSettingDisplay {
                dateTimeSettings: dateTimeSettings
            }
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
