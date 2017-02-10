import QtQuick 2.1
import Sailfish.Silica 1.0

BackgroundItem {
    id: root

    property alias text: label.text
    property real topPadding: Theme.paddingLarge
    property real bottomPadding: 2*Theme.paddingLarge

    implicitHeight: label.height + topPadding + bottomPadding
    width: label.implicitWidth + 2*Theme.paddingLarge
    opacity: enabled ? 1.0 : 0.4

    Label {
        id: label

        y: topPadding
        x: Theme.paddingMedium
        width: parent.width - 2*Theme.paddingMedium
        horizontalAlignment: Text.AlignHCenter
        color: root.down ? Theme.highlightColor : Theme.primaryColor
        font.pixelSize: Theme.fontSizeMedium
        textFormat: Text.AutoText
        wrapMode: Text.Wrap
    }
}
