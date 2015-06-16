import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    id: coverArt

    property alias status: coverImage.status
    property alias source: coverImage.source

    anchors.fill: parent

    Image {
        id: coverImage

        asynchronous: true
        anchors.fill: parent
        sourceSize.width: width
        sourceSize.height: width
        fillMode: Image.PreserveAspectFit
    }

    OpacityRampEffect {
        enabled: coverImage.status === Image.Ready
        offset: 0.0
        slope: 1.0
        direction: isLandscape ? OpacityRamp.TopToBottom : OpacityRamp.BottomToTop
        sourceItem: coverImage
    }
}
