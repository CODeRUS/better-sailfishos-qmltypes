import QtQuick 2.0
import Sailfish.Silica 1.0

Rectangle {
    z: 10
    width: parent.width
    height: column.height + column.y + Theme.paddingMedium
    color: Theme.rgba(Theme.highlightBackgroundColor, Theme.highlightBackgroundOpacity)

    Column {
        id: column
        y: Theme.paddingMedium
        x: Theme.paddingLarge
        width: parent.width - 2 * x

        DebugLabel {
            text: "Margins t " +  zoomableImage.topMargin + " b " + zoomableImage.bottomMargin + " l " + zoomableImage.leftMargin + " r " + zoomableImage.rightMargin
        }
        DebugLabel {
            text: "Content w " +  zoomableImage.contentWidth + " h " + zoomableImage.contentHeight + " x " + zoomableImage.contentX + " y " + zoomableImage.contentY
        }
        DebugLabel {
            text: "Photo w " + zoomableImage.photo.width + " h " + zoomableImage.photo.height + " iw " + zoomableImage.photo.implicitWidth + " ih " + zoomableImage.photo.implicitHeight
        }
        DebugLabel {
            text: "Scale " + zoomableImage._scale.toFixed(1) + " minimum " + zoomableImage._minimumScale.toFixed(1) + " fitted " + zoomableImage._fittedScale
        }
        DebugLabel {
            text: "Crop w " + editor.width + " h " + editor.height + " x " + editor.x + " y " + editor.y
        }
        DebugLabel {
            text: "Rotation base " + zoomableImage.baseRotation + " image " + zoomableImage.imageRotation
        }
        DebugLabel {
            text: "Orientation meta " + metadata.orientation + " orientation " + zoomableImage.orientation
        }
    }
}
