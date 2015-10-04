import QtQuick 2.0
import Sailfish.Silica 1.0

Label {
    id: root

    property bool pressed: mouseArea.pressed

    color: Theme.highlightColor
    width: parent.width
    wrapMode: Text.Wrap
    textFormat: Text.StyledText
    height: implicitHeight

    signal clicked

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onClicked: root.clicked()
    }
}
