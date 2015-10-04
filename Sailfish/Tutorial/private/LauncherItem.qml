import QtQuick 2.0
import Sailfish.Silica 1.0

BackgroundItem {
    property int row
    property int column

    property int _rows: 6
    property int _columns: 4

    property int _horizontalMargin: Screen.sizeCategory >= Screen.Large ? 120 : 0
    property int _verticalMargin: Screen.sizeCategory >= Screen.Large ? 50 : 20
    property int _cellWidth: Screen.sizeCategory >= Screen.Large ? 324 : 135
    property int _cellHeight: Screen.sizeCategory >= Screen.Large ? 320 : 150

    highlightedColor: Theme.rgba(tutorialTheme.highlightColor, 0.3)

    x: (_horizontalMargin + column*_cellWidth) * xScale
    y: (_verticalMargin + row*_cellHeight) * yScale

    width: _cellWidth * xScale
    height: _cellHeight * yScale
    enabled: false
}
