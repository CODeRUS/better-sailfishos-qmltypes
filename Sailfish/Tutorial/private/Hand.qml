import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    id: hand

    property real handScale
    property real pressRotate
    property real pressTranslate
    property real dragRotate
    property real dragTranslate

    readonly property Item palm: palm
    readonly property Item thumb: thumb
    readonly property Item pressCircle: pressCircle

    anchors.centerIn: parent
    width: parent.width
    height: parent.height
    opacity: 0.0

    Item {
        width: palm.width
        height: palm.height
        anchors {
            right: parent.horizontalCenter
            rightMargin: -parent.width * 0.5
            bottom: parent.verticalCenter
            bottomMargin: -parent.height * 0.5
        }

        // ensure that palm and thumb fade together
        layer.enabled: parent.opacity != 1.0 && opacity != 0.0

        Image {
            id: palm

            source: Qt.resolvedUrl("file:///usr/share/sailfish-tutorial/graphics/tutorial-gesture-palm.svg")
            sourceSize.height: 1014 * hand.handScale
            fillMode: Image.PreserveAspectFit
        }

        Image {
            id: thumb

            property real initialYOffset: height * -0.12
            property real yOffset: initialYOffset

            source: Qt.resolvedUrl("file:///usr/share/sailfish-tutorial/graphics/tutorial-gesture-thumb.svg")
            sourceSize.height: 839 * hand.handScale
            fillMode: Image.PreserveAspectFit
            anchors {
                horizontalCenter: palm.horizontalCenter
                horizontalCenterOffset: width * 0.45
                verticalCenter: palm.verticalCenter
                verticalCenterOffset: yOffset
            }

            Image {
                id: pressCircle

                property real reducedScale: 0.83

                source: Qt.resolvedUrl("file:///usr/share/sailfish-tutorial/graphics/tutorial-circle-large.svg")
                sourceSize.height: 184 * hand.handScale
                fillMode: Image.PreserveAspectFit
                anchors {
                    horizontalCenter: thumb.left
                    horizontalCenterOffset: thumb.width * 0.06
                    verticalCenter: thumb.top
                    verticalCenterOffset: thumb.height * 0.2
                }
            }
        }
    }
}
