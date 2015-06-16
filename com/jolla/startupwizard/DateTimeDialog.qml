import QtQuick 2.0
import Sailfish.Silica 1.0
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
            // If time format has never been set, default to 24hr.
            timeFormatConfig.value = "24"
        }

        _reloadDateString()
    }

    SilicaFlickable {
        id: flickable

        anchors.fill: parent

        property int baseHeight: header.height + headingLabel.height + descriptionLabel.height + bottomDetails.height + 3*Theme.paddingLarge
        contentHeight: Math.max(baseHeight, isPortrait ? Screen.height : Screen.width)

        DialogHeader {
            id: header
            dialog: root
        }

        Label {
            id: headingLabel

            //% "Date and time"
            text: qsTrId("startupwizard-he-time_and_date")

            x: Theme.horizontalPageMargin
            width: parent.width - x*2
            anchors.top: header.bottom
            wrapMode: Text.WordWrap
            font {
                family: Theme.fontFamilyHeading
                pixelSize: Theme.fontSizeExtraLarge
            }
            color: Theme.highlightColor
        }

        Label {
            id: descriptionLabel

            //: Current time and date. %1=date, %2=time
            //% "%1 at %2"
            text: qsTrId("startupwizard-la-current_time_and_date").arg(_dateString).arg(timeSettingDisplay.value)

            x: Theme.horizontalPageMargin
            width: parent.width - x*2
            anchors {
                top: headingLabel.bottom
                topMargin: Theme.paddingLarge
            }

            wrapMode: Text.WordWrap
            font.pixelSize: Theme.fontSizeExtraSmall
            color: Theme.rgba(Theme.highlightColor, 0.9)
        }

        Item {
            id: spacer

            height: flickable.contentHeight - flickable.baseHeight

            anchors {
                top: descriptionLabel.bottom
                left: parent.left
                right: parent.right
            }
        }

        Column {
            id: bottomDetails

            anchors {
                top: spacer.bottom
                topMargin: Theme.paddingLarge
                left: parent.left
                right: parent.right
            }

            Label {
                //: Heading above buttons that allow current time and date settings to be changed
                //% "Not quite right? Change here"
                text: qsTrId("startupwizard-he-change_time_and_date")
                x: Theme.horizontalPageMargin
                width: parent.width - x*2
                wrapMode: Text.Wrap
                height: Theme.itemSizeSmall
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: Theme.fontSizeExtraSmall
                color: Theme.rgba(Theme.highlightColor, 0.9)
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
