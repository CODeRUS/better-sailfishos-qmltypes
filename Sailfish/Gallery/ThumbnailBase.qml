import QtQuick 2.0
import org.nemomobile.thumbnailer 1.0

// Base item for thumbnails in a Grid to get default behavior for free.
// Make sure that this is a top level delegate item for a grid or
// some functionality (opacity, ...) will be lost
MouseArea {
    id: thumbnail

    property url source
    property bool down: pressed && containsMouse
    property string mimeType: model && model.mimeType ? model.mimeType : ""
    property bool pressedAndHolded
    property int size: GridView.view.cellSize
    property real contentYOffset
    property real contentXOffset
    property GridView grid: GridView.view

    width: size
    height: size
    opacity: grid
             ? (grid.currentIndex === index && grid.unfocusHighlightEnabled
                ? 1.0
                : grid._unfocusedOpacity)
             : 1.0

    // Default behavior for each thumbnail
    onPressed: if (grid) grid.currentIndex = index
    onPressAndHold: pressedAndHolded = true
    onReleased: pressedAndHolded = false
    onCanceled: pressedAndHolded = false

}
