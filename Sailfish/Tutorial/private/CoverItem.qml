import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Tutorial 1.0

BackgroundItem {
    property int row
    property int column

    property int _rows: 2
    property int _columns: 3

    property int _horizontalMargin: (Screen.sizeCategory >= Screen.Large ? 133 : 25) * xScale
    property int _verticalMargin: (Screen.sizeCategory >= Screen.Large ? 195 : 75) * yScale
    property int _horizontalSpacing: (Screen.sizeCategory >= Screen.Large ? 107 : 41) * xScale
    property int _verticalSpacing: (Screen.sizeCategory >= Screen.Large ? 107 : 41) * yScale

    x: _horizontalMargin + column * width + column * _horizontalSpacing
    y: _verticalMargin + row * height + row * _verticalSpacing
    width: (Screen.sizeCategory >= Screen.Large ? 352 : 136) * xScale
    height: (Screen.sizeCategory >= Screen.Large ? 562 : 217) * yScale

    highlightedColor: Theme.rgba(tutorialTheme.highlightColor, 0.3)
    enabled: false
}
