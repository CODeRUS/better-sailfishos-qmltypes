import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Media 1.0
import com.jolla.settings.system 1.0
import org.nemomobile.systemsettings 1.0

Item {
    // Object which should containt tone related properties.
    property QtObject toneSettings

    height: toneItems.height
    width: parent.width

    AlarmToneModel {
        id: alarmToneModel
    }

    MetadataReader {
        id: metadataReader
    }

    Column {
        id: toneItems

        width: parent.width

        AmbienceToneItem {
            //% "Ringtone"
            defaultText: qsTrId(" jolla-gallery-ambience-sound-la-ringtone")
            //% "Current ringtone"
            currentText: qsTrId(" jolla-gallery-ambience-sound-la-current-ringtone")
            enabledProperty: "ringerToneEnabled"
            fileProperty: "ringerToneFile"
            displayNameProperty: "ringerToneFileDisplayName"
        }

        AmbienceToneItem {
            //% "Internet call"
            defaultText: qsTrId(" jolla-gallery-ambience-sound-la-internet-call")
            //% "Current internet call tone"
            currentText: qsTrId(" jolla-gallery-ambience-sound-la-current-internet-call-tone")
            enabledProperty: "internetCallToneEnabled"
            fileProperty: "internetCallToneFile"
            displayNameProperty: "internetCallToneFileDisplayName"
        }

        AmbienceToneItem {
            //% "Message"
            defaultText: qsTrId(" jolla-gallery-ambiencesound-la-message")
            //% "Current message tone"
            currentText: qsTrId(" jolla-gallery-ambience-sound-la-current-message-tone")
            enabledProperty: "messageToneEnabled"
            fileProperty: "messageToneFile"
            displayNameProperty: "messageToneFileDisplayName"
        }

        AmbienceToneItem {
            //% "Chat"
            defaultText: qsTrId(" jolla-gallery-ambience-sound-la-chat")
            //% "Current chat tone"
            currentText: qsTrId(" jolla-gallery-ambience-sound-la-current-chat-tone")
            enabledProperty: "chatToneEnabled"
            fileProperty: "chatToneFile"
            displayNameProperty: "chatToneFileDisplayName"
        }

        AmbienceToneItem {
            //% "Mail"
            defaultText: qsTrId(" jolla-gallery-ambience-sound-la-mail")
            //% "Current mail tone"
            currentText: qsTrId(" jolla-gallery-ambience-sound-la-current-mail-tone")
            enabledProperty: "mailToneEnabled"
            fileProperty: "mailToneFile"
            displayNameProperty: "mailToneFileDisplayName"
        }

        AmbienceToneItem {
            //% "Calendar"
            defaultText: qsTrId(" jolla-gallery-ambience-sound-la-calendar")
            //% "Current calendar alarm tone"
            currentText: qsTrId(" jolla-gallery-ambience-sound-la-current-calendar-tone")
            enabledProperty: "calendarToneEnabled"
            fileProperty: "calendarToneFile"
            displayNameProperty: "calendarToneFileDisplayName"
        }

        AmbienceToneItem {
            //% "Clock alarm"
            defaultText: qsTrId(" jolla-gallery-ambience-sound-la-clock")
            //% "Current clock alarm tone"
            currentText: qsTrId(" jolla-gallery-ambience-sound-la-current-clock-tone")
            enabledProperty: "clockAlarmToneEnabled"
            fileProperty: "clockAlarmToneFile"
            displayNameProperty: "clockAlarmToneFileDisplayName"
        }
    }


    Component {
        id: dialogComponent

        SoundDialog {
            alarmModel: alarmToneModel
        }
    }
}
