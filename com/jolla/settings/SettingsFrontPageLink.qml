import QtQuick 2.0
import Sailfish.Silica 1.0

SettingItem {
    id: root

    property alias name: label.text
    property url iconSource
    property url pageSource
    property bool useHighlightColor: true

    implicitHeight: Theme.itemSizeMedium

    onClicked: pageStack.push(pageSource.toString(), {})

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop {
                position: 0.0
                color: Theme.rgba(Theme.highlightBackgroundColor, 0.1)
            }
            GradientStop {
                position: 1.0
                color: "transparent"
            }
        }
    }

    Image {
        id: icon
        anchors {
            right: parent.right
            rightMargin: Theme.horizontalPageMargin
            verticalCenter: parent.verticalCenter
        }
        source: "image://theme/icon-m-right?" + (root.highlighted ? Theme.highlightColor : Theme.primaryColor)
    }
    Label {
        id: label
        truncationMode: TruncationMode.Fade
        color: root.highlighted ? Theme.highlightColor : Theme.primaryColor
        horizontalAlignment: Text.AlignRight
        anchors {
            left: parent.left
            leftMargin: Theme.horizontalPageMargin
            verticalCenter: parent.verticalCenter
            right: icon.left
            rightMargin: Theme.paddingMedium
        }
    }
}
