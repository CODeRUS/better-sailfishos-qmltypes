import QtQuick 2.6
import Sailfish.Silica 1.0

MouseArea {
    id: root

    property alias text: showMore.text
    property bool highlighted: containsMouse
    property alias horizontalAlignment: showMore.horizontalAlignment

    //: Prompt to show more of the available content
    //% "Show more"
    property string defaultText: qsTrId("components-bt-show_more")

    implicitWidth: showMore.width + Theme.paddingSmall + dots.width
    implicitHeight: showMore.height

    Label {
        id: showMore

        anchors {
            right: root.horizontalAlignment === Text.AlignLeft ? undefined: dots.left
            rightMargin: Theme.paddingSmall
        }

        text: root.defaultText
        font.pixelSize: Theme.fontSizeExtraSmall
        color: highlighted ? palette.secondaryHighlightColor : palette.secondaryColor
        truncationMode: TruncationMode.Fade
    }

    HighlightImage {
        id: dots

        anchors {
            left: root.horizontalAlignment === Text.AlignLeft ? showMore.right: undefined
            right: root.horizontalAlignment === Text.AlignLeft ? undefined: parent.right
            leftMargin: Theme.paddingSmall
            verticalCenter: showMore.verticalCenter
        }

        width: Theme.iconSizeSmallPlus
        height: width
        sourceSize.width: width
        sourceSize.height: height

        source: "image://theme/icon-lock-more"
        highlighted: root.highlighted
        opacity: root.highlighted ? 1.0 : 0.7   // match label secondary opacity
    }
}
