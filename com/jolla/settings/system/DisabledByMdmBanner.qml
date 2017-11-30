import QtQuick 2.0
import Sailfish.Silica 1.0

Rectangle {
    property bool active: true
    property alias text: lockedLabel.text

    width: parent.width
    height: active ? implicitHeight : 0
    opacity: active ? 1.0 : 0.0
    visible: opacity > 0.0
    implicitHeight: lockedLabel.implicitHeight + 2*Theme.paddingLarge
    color: Theme.rgba(Theme.highlightDimmerColor, 0.5)
    Behavior on opacity { FadeAnimation {} }
    Behavior on height { NumberAnimation { duration: 200; easing.type: Easing.InOutQuad } }

    Label {
        id: lockedLabel
        y: Theme.paddingLarge
        x: Theme.horizontalPageMargin
        width: parent.width - 2*Theme.horizontalPageMargin
        font.pixelSize: Theme.fontSizeExtraLarge
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
        textFormat: Text.StyledText
        //% "Disabled by Sailfish Device Manager"
        text: qsTrId("settings_system-la-disabled_by_device_manager")
        color: Theme.highlightColor
    }
}
