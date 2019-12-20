import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    property alias name: nameLabel.text
    property alias value: valueLabel.text
    property alias valueLabel: valueLabel

    width: parent.width
    height: flow.height + Theme.paddingSmall*2

    Flow {
        id: flow

        x: Theme.horizontalPageMargin
        width: parent.width - x*2
        y: Theme.paddingSmall

        Label {
            id: nameLabel

            width: implicitWidth + Theme.paddingMedium
            color: Theme.highlightColor
        }
        Label {
            id: valueLabel

            wrapMode: Text.WrapAnywhere
            width: Math.min(implicitWidth, flow.width)
            color: Theme.secondaryHighlightColor
        }
    }
}
