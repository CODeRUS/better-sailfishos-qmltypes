import QtQuick 2.0
import Sailfish.Silica 1.0
import com.jolla.settings 1.0

MouseArea {
    id: appItem

    property alias icon: appIcon.icon
    property alias iconStatus: appIcon.status
    property alias text: appTitle.text
    property alias textColor: appTitle.color

    property bool down: pressed && containsMouse
    property bool highlighted: down

    objectName: "LauncherGridItem"

    LauncherIcon {
        id: appIcon

        y: Math.round((parent.height - (height + appTitle.height)) / 2)
        anchors.horizontalCenter: parent.horizontalCenter
        opacity: appItem.enabled ? 1 : Theme.opacityFaint
        pressed: highlighted
        icon: launcher ? launcher.iconId : ""
    }

    Text {
        id: appTitle

        anchors {
            top: appIcon.bottom
            topMargin: Theme.paddingSmall
            left: parent.left
            right: parent.right
        }
        horizontalAlignment: Text.AlignHCenter
        opacity: appItem.enabled ? 1 : Theme.opacityFaint
        font.pixelSize: Theme.fontSizeTiny
        elide: Text.ElideRight
        textFormat: Text.PlainText
        color: highlighted ? Theme.highlightColor : Theme.primaryColor
        text: launcher ? launcher.title : ""
    }
}
