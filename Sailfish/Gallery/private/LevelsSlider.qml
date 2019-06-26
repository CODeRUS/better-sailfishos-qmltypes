import QtQuick 2.0
import Sailfish.Silica 1.0

Slider {
    signal reset

    value: 0.0
    maximumValue: 1.0
    minimumValue: -1.0

    color: Theme.lightPrimaryColor
    backgroundColor: Theme.lightSecondaryColor
    valueLabelColor: Theme.lightPrimaryColor
    colorScheme: Theme.LightOnDark

    width: parent.width
    rightMargin: resetButton.width + Theme.horizontalPageMargin + Theme.paddingMedium

    IconButton {
        id: resetButton
        onClicked: reset()
        anchors {
            right: parent.right
            verticalCenter: _progressBarItem.verticalCenter
            rightMargin: Theme.horizontalPageMargin
        }

        Behavior on opacity { FadeAnimator {}}
        opacity: enabled ? 1.0 : 0.0
        enabled: value !== 0
        icon.source: "image://theme/icon-camera-reset?" + Theme.lightPrimaryColor
    }
}
