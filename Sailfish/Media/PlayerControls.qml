import QtQuick 2.0
import Sailfish.Silica 1.0
import "scripts/Locale.js" as Locale

// The mouse area intercepts clicks in immediate surrounds of the controls
// so miss hits don't have any unintended consequences.
MouseArea {
    id: controls

    default property alias buttons: buttons.data
    property alias buttonSpacing: buttons.spacing

    property int position
    onPositionChanged: positionSlider.value = position / 1000
    property int duration
    property alias seekEnabled: positionSlider.enabled

    signal seek(int position)

    implicitHeight: positionSlider.height + buttons.height

    Slider {
        id: positionSlider

        anchors { left: parent.left; right: parent.right; bottom: buttons.top }

        height: Theme.itemSizeSmall
        handleVisible: false
        minimumValue: 0
        maximumValue: controls.duration / 1000
        valueText: Locale.formatDuration(value)

        onReleased: controls.seek(value * 1000)
    }

    Row {  // Rectangle
        id: buttons

        anchors { horizontalCenter: parent.horizontalCenter; bottom: parent.bottom }
    }
}
