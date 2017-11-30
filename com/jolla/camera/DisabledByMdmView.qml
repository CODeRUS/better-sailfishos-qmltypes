import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Policy 1.0

Loader {
    anchors.fill: parent
    active: opacity > 0.0
    opacity: !AccessPolicy.cameraEnabled ? 1.0 : 0.0
    Behavior on opacity { FadeAnimation { duration: 400 } }

    sourceComponent: Rectangle {
        color: Theme.rgba(Theme.highlightDimmerColor, 0.8)

        TouchBlocker {
            anchors.fill: parent
            target: parent
        }

        Image {
            source: "image://theme/icon-m-device-lock?" + Theme.highlightColor
            anchors {
                horizontalCenter: parent.horizontalCenter
                bottom: lockedLabel.top
                bottomMargin: Theme.paddingMedium
            }
        }

        Label {
            id: lockedLabel
            x: Theme.horizontalPageMargin
            width: parent.width - 2*Theme.horizontalPageMargin
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: Theme.fontSizeExtraLarge
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            //% "Camera disabled by Sailfish Device Manager."
            text: qsTrId("jolla-camera-la-camera_disabled_by_device_manager")
            color: Theme.highlightColor
        }
    }
}
