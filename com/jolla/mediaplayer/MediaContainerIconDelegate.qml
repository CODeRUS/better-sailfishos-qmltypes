import QtQuick 2.0
import Sailfish.Silica 1.0

MediaContainerListDelegate {
    id: root

    property string iconSource

    leftPadding: Theme.itemSizeExtraLarge + Theme.paddingLarge

    Image {
        x: Theme.itemSizeExtraLarge - width
        source: root.iconSource + (root.highlighted && root.iconSource !== "" ? ("?" + Theme.highlightColor)
                                                                              : "")
        anchors.verticalCenter: parent.verticalCenter
    }
}
