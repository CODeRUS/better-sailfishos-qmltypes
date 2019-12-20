import QtQuick 2.0
import Sailfish.Silica 1.0
import org.nemomobile.messages.internal 1.0

Label {
    id: characterCountLabel

    property bool active: messageText.length > 0
    property alias messageText: characterCounter.text

    SmsCharacterCounter {
        id: characterCounter
    }

    color: Theme.highlightColor
    font.pixelSize: Theme.fontSizeTiny
    horizontalAlignment: Qt.AlignRight
    text: active ? "%1/%2".arg(characterCounter.remainingCharacterCount)
                          .arg(characterCounter.messageCount)
                 : "159/1"
    opacity: active ? 1.0 : 0.0
    Behavior on opacity { FadeAnimation {}}
}
