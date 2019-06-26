import QtQuick 2.6
import Sailfish.Silica 1.0

BackgroundItem {
    id: root

    property alias text: label.text
    property alias topPadding: label.topPadding
    property alias bottomPadding: label.bottomPadding

    implicitHeight: label.implicitHeight
    width: label.implicitWidth + 2*Theme.paddingLarge
    opacity: enabled ? 1.0 : 0.4

    Label {
        id: label

        x: Theme.paddingMedium
        topPadding: Theme.paddingLarge
        bottomPadding: Theme.paddingLarge * 2
        width: parent.width - 2*Theme.paddingMedium
        horizontalAlignment: Text.AlignHCenter
        color: root.down ? Theme.highlightColor : Theme.primaryColor
        font.pixelSize: Theme.fontSizeMedium
        textFormat: Text.AutoText
        wrapMode: Text.Wrap
    }
}
