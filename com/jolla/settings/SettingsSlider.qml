import QtQuick 2.4
import Sailfish.Silica 1.0
import Sailfish.Silica.private 1.0 as Private

Private.SliderBase {
    id: slider

    width: root.width
    _highlightItem: highlight
    _backgroundItem: background
    _progressBarItem: progressBar

    Rectangle {
        id: background

        x: slider.leftMargin
        width: slider._grooveWidth
        y: slider._extraPadding + _backgroundTopPadding
        height: progressBar.height
        radius: width
        color: slider.highlighted ? slider.secondaryHighlightColor : slider.backgroundColor
    }

    Rectangle {
        id: progressBar

        x: background.x
        anchors.verticalCenter: background.verticalCenter
        width: slider._progressBarWidth
        height: Math.round(Theme.paddingSmall * 0.75)
        visible: sliderValue > minimumValue
        radius: width
        color: slider.highlighted ? slider.highlightColor : slider.color
    }

    Rectangle {
        id: highlight

        x: slider._highlightX
        width: Theme.iconSizeSmall
        height: width
        radius: width

        anchors.verticalCenter: background.verticalCenter
        visible: handleVisible
        color: slider.highlighted ? slider.highlightColor : slider.color
    }
}
