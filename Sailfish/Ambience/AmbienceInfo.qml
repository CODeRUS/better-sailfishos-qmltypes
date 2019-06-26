import QtQuick 2.2
import Sailfish.Ambience 1.0

ContentInfo {
    contentType: ContentInfo.Ambience

    property string mimeType
    property string fileName
    property bool readOnly
    property string displayName
    property bool favorite
    property int colorScheme
    property int version
    property url wallpaperUrl
    property url applicationWallpaperUrl
    property color highlightColor
    property color secondaryHighlightColor
    property color primaryColor
    property color secondaryColor
    property int ringerVolume
    property bool ringerToneEnabled
    property bool messageToneEnabled
    property bool mailToneEnabled
    property bool internetCallToneEnabled
    property bool chatToneEnabled
    property bool calendarToneEnabled
    property bool clockAlarmToneEnabled
    property alias resources: ambienceResources

    QtObject {
        id: ambienceResources

        property alias ringerToneFile: ringerTone
        property alias messageToneFile: messageTone
        property alias mailToneFile: mailTone
        property alias internetCallToneFile: internetCallTone
        property alias chatToneFile: chatTone
        property alias calendarToneFile: calendarTone
        property alias clockAlarmToneFile: clockAlarmTone
    }

    Tone { id: ringerTone }
    Tone { id: messageTone }
    Tone { id: mailTone }
    Tone { id: internetCallTone }
    Tone { id: chatTone }
    Tone { id: calendarTone }
    Tone { id: clockAlarmTone }
}
