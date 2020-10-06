import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
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

        Rectangle {
            anchors.fill: parent
            gradient: Gradient {
                GradientStop { position: 0.0; color: Qt.rgba(0, 0, 0, Theme.opacityHigh) }
                GradientStop { position: 0.3; color: "transparent" }
            }
        }
    }
}
