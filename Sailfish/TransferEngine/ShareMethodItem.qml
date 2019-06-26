import QtQuick 2.0
import Sailfish.Silica 1.0

BackgroundItem {
    property alias iconSource: icon.source
    property alias text: textLabel.text
    property alias description: descriptionLabel.text

    Image {
        id: icon

        x: Theme.horizontalPageMargin
        anchors.verticalCenter: parent.verticalCenter
        source: model.accountIcon
    }

    Label {
        id: textLabel

        color: highlighted ? Theme.highlightColor : Theme.primaryColor
        truncationMode: TruncationMode.Fade
        anchors {
            left: icon.right
            leftMargin: Theme.paddingMedium
            verticalCenter: parent.verticalCenter
        }
        width: Math.min(implicitWidth, parent.width - x - Theme.horizontalPageMargin)
    }
    Label {
        id: descriptionLabel

        color: highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
        truncationMode: TruncationMode.Fade
        anchors {
            left: textLabel.right
            leftMargin: Theme.paddingSmall
            right: parent.right
            rightMargin: Theme.horizontalPageMargin
            verticalCenter: parent.verticalCenter
        }
        visible: text.length > 0
    }
}
