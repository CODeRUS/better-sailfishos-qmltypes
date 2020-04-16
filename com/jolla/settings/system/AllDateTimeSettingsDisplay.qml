/****************************************************************************
**
** Copyright (c) 2013-2019 Jolla Ltd.
** Copyright (c) 2019 Open Mobile Platform LLC.
** License: Proprietary
**
****************************************************************************/
import QtQuick 2.0
import Sailfish.Silica 1.0
import org.nemomobile.systemsettings 1.0
import org.nemomobile.ofono 1.0
import Sailfish.Policy 1.0

Column {
    id: root

    property var dateTimeSettings
    property alias defaultDate: dateSettingDisplay.defaultDate

    property bool showAutoUpdateOptions: true
    property bool overrideAutoUpdatedValues

    width: parent.width

    DisabledByMdmBanner {
         id: disabledByMdmBanner
         active: !AccessPolicy.dateTimeSettingsEnabled
    }

    TextSwitch {
        id: autoTimeUpdate
        //% "Automatic time update"
        text: qsTrId("settings_datetime-la-automatic_time_update")
        automaticCheck: false
        checked: dateTimeSettings.automaticTimeUpdate
        enabled: !disabledByMdmBanner.active
        visible: root.showAutoUpdateOptions
        onClicked: {
            var newValue = !checked
            dateTimeSettings.automaticTimeUpdate = newValue
            if (modemManager.availableModems.length > 0) {
                dateTimeSettings.automaticTimezoneUpdate = newValue
            } else {
                // Automatic time zone update requires mobile data
                dateTimeSettings.automaticTimezoneUpdate = false
            }
        }
    }

    CurrentTimeZoneSettingDisplay {
        enabled: !disabledByMdmBanner.active
                 && (!dateTimeSettings.automaticTimezoneUpdate || root.overrideAutoUpdatedValues)
        dateTimeSettings: root.dateTimeSettings
    }

    CurrentDateSettingDisplay {
        id: dateSettingDisplay
        enabled: !disabledByMdmBanner.active
                 && (!dateTimeSettings.automaticTimeUpdate || root.overrideAutoUpdatedValues)
        dateTimeSettings: root.dateTimeSettings
    }

    CurrentTimeSettingDisplay {
        enabled: dateSettingDisplay.enabled
        dateTimeSettings: root.dateTimeSettings
    }

    Use24HourClockSettingDisplay {
        dateTimeSettings: root.dateTimeSettings
    }

    OfonoModemManager {
        id: modemManager
    }
}
