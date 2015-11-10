import QtQml 2.0
import QtQml.Models 2.1
import Sailfish.Ambience 1.0

QtObject {
    id: ambiences

    // When changing value names here, change also in AmbienceSettingsPage
    property var properties: [
        "ringerVolume",
        "ringerTone",
        "internetCallTone",
        "messageTone",
        "chatTone",
        "mailTone",
        "calendarTone",
        "clockAlarmTone"
    ]

    property alias ringerVolume: ringerVolume
    property alias ringerTone: ringerTone
    property alias internetCallTone: internetCallTone
    property alias messageTone: messageTone
    property alias chatTone: chatTone
    property alias mailTone: mailTone
    property alias calendarTone: calendarTone
    property alias clockAlarmTone: clockAlarmTone

    //% "Sounds and feedback"
    readonly property string _soundsSection: qsTrId("jolla-gallery-ambience-la-sounds_and_feedback")
    //% "Tones"
    readonly property string _tonesSection: qsTrId("jolla-gallery-ambience-la-tones")

    property list<QtObject> resources: [
        VolumeAction {
            id: ringerVolume
            section: ambiences._soundsSection
            property: "ringerVolume"
            // "Ambience specific ringtone volume"
            //% "Ringtone volume"
            label: qsTrId("jolla-gallery-ambience-la-ringtone-volume")
            defaultVolume: 80
        },
        ToneAction {
            id: ringerTone
            section: ambiences._tonesSection
            property: "ringerTone"
            //% "Ringtone"
            label: qsTrId(" jolla-gallery-ambience-sound-la-ringtone")
            //% "Current ringtone"
            currentText: qsTrId(" jolla-gallery-ambience-sound-la-current-ringtone")
        },
        ToneAction {
            id: internetCallTone
            section: ambiences._tonesSection
            property: "internetCallTone"
            //% "Internet call"
            label: qsTrId(" jolla-gallery-ambience-sound-la-internet-call")
            //% "Current internet call tone"
            currentText: qsTrId(" jolla-gallery-ambience-sound-la-current-internet-call-tone")
        },
        ToneAction {
            id: messageTone
            section: ambiences._tonesSection
            property: "messageTone"
            //% "Message"
            label: qsTrId(" jolla-gallery-ambiencesound-la-message")
            //% "Current message tone"
            currentText: qsTrId(" jolla-gallery-ambience-sound-la-current-message-tone")
        },
        ToneAction {
            id: chatTone
            section: ambiences._tonesSection
            property: "chatTone"
            //% "Chat"
            label: qsTrId(" jolla-gallery-ambience-sound-la-chat")
            //% "Current chat tone"
            currentText: qsTrId(" jolla-gallery-ambience-sound-la-current-chat-tone")
        },
        ToneAction {
            id: mailTone
            section: ambiences._tonesSection
            property: "mailTone"
            //% "Mail"
            label: qsTrId(" jolla-gallery-ambience-sound-la-mail")
            //% "Current mail tone"
            currentText: qsTrId(" jolla-gallery-ambience-sound-la-current-mail-tone")
        },
        ToneAction {
            id: calendarTone
            section: ambiences._tonesSection
            property: "calendarTone"
            //% "Calendar"
            label: qsTrId(" jolla-gallery-ambience-sound-la-calendar")
            //% "Current calendar alarm tone"
            currentText: qsTrId(" jolla-gallery-ambience-sound-la-current-calendar-tone")
        },
        ToneAction {
            id: clockAlarmTone
            section: ambiences._tonesSection
            property: "clockAlarmTone"
            //% "Clock alarm"
            label: qsTrId(" jolla-gallery-ambience-sound-la-clock")
            //% "Current clock alarm tone"
            currentText: qsTrId(" jolla-gallery-ambience-sound-la-current-clock-tone")
        }
    ]
}
