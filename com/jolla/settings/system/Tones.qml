/****************************************************************************
**
** Copyright (c) 2013-2019 Jolla Ltd.
** Copyright (c) 2019 Open Mobile Platform LLC.
** License: Proprietary
**
****************************************************************************/
import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Media 1.0
import com.jolla.settings 1.0
import com.jolla.settings.system 1.0
import org.nemomobile.systemsettings 1.0
import org.nemomobile.ofono 1.0

Item {
    // Object which should contain tone related properties.
    property QtObject toneSettings

    height: toneItems.height
    width: parent.width

    MetadataReader {
        id: metadataReader
    }

    OfonoModemManager {
        id: modemManager
    }

    Column {
        id: toneItems

        width: parent.width

        ToneItem {
            visible: modemManager.availableModems.length > 0
            //% "Ringtone"
            defaultText: qsTrId("settings_sound-la-ringtone")
            //% "Current ringtone"
            currentText: qsTrId("settings_sound-la-current_ringtone")
            enabledProperty: "ringerToneEnabled"
            fileProperty: "ringerToneFile"
        }

/*
  Re-enable once we have VOIP support JB#4599
        ToneItem {
            //% "Internet call"
            defaultText: qsTrId("settings_sound-la-internet_call")
            //% "Current internet call tone"
            currentText: qsTrId("settings_sound-la-current_internet_call_tone")
            enabledProperty: "internetCallToneEnabled"
            fileProperty: "internetCallToneFile"
        }
*/

        ToneItem {
            visible: modemManager.availableModems.length > 0
            //% "Message"
            defaultText: qsTrId("settings_sound-la-message")
            //% "Current message tone"
            currentText: qsTrId("settings_sound-la-current_message_tone")
            enabledProperty: "messageToneEnabled"
            fileProperty: "messageToneFile"
        }

        ToneItem {
            //% "Chat"
            defaultText: qsTrId("settings_sound-la-chat")
            //% "Current chat tone"
            currentText: qsTrId("settings_sound-la-current_chat_tone")
            enabledProperty: "chatToneEnabled"
            fileProperty: "chatToneFile"
        }

        ToneItem {
            //% "Mail"
            defaultText: qsTrId("settings_sound-la-mail")
            //% "Current mail tone"
            currentText: qsTrId("settings_sound-la-current_mail_tone")
            enabledProperty: "mailToneEnabled"
            fileProperty: "mailToneFile"
        }

        ToneItem {
            //% "Clock alarm"
            defaultText: qsTrId("settings_sound-la-clock")
            //% "Current clock alarm tone"
            currentText: qsTrId("settings_sound-la-current_clock_tone")
            enabledProperty: "clockAlarmToneEnabled"
            fileProperty: "clockAlarmToneFile"
        }

        ToneItem {
            //% "Calendar"
            defaultText: qsTrId("settings_sound-la-calendar")
            //% "Current calendar alarm tone"
            currentText: qsTrId("settings_sound-la-current_calendar_tone")
            enabledProperty: "calendarToneEnabled"
            fileProperty: "calendarToneFile"
        }
    }
}
