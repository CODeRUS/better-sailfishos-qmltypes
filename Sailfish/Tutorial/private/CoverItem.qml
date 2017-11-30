import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Tutorial 1.0

BackgroundItem {
    property int row
    property int column

    property int _horizontalMargin: applicationSwitcher.horizontalMargin
    property int _verticalMargin: applicationSwitcher.verticalMargin
    property int _horizontalSpacing: applicationSwitcher.horizontalSpacing
    property int _verticalSpacing: applicationSwitcher.verticalSpacing

    x: _horizontalMargin + column * width + column * _horizontalSpacing
    y: _verticalMargin + row * height + row * _verticalSpacing
    width: (Screen.sizeCategory >= Screen.Large ? 352 : 136) * xScale
    height: (Screen.sizeCategory >= Screen.Large ? 562 : 218) * yScale

    highlightedColor: Theme.rgba(tutorialTheme.highlightColor, 0.3)
    enabled: false
}
