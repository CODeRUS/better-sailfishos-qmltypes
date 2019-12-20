import QtQuick 2.0
import Sailfish.Silica 1.0

Rectangle {
    z: 10
    width: parent.width
    height: column.height + column.y + Theme.paddingMedium
    color: Theme.rgba(Theme.highlightBackgroundColor, Theme.highlightBackgroundOpacity)

    property Flickable flickable
    Component.onCompleted: {
        if (!flickable) {
            var parentItem = parent
            while (parentItem) {
                if (parentItem.maximumFlickVelocity) {
                    flickable = parentItem
                    parent = flickable
                    break
                }
                parentItem = parentItem.parent
            }
        }
    }

    Column {
        id: column
        y: Theme.paddingMedium
        x: Theme.paddingLarge
        width: parent.width - 2 * x

        DebugLabel {
            text: "Margins t " +  flickable.topMargin + " b " + flickable.bottomMargin + " l " + flickable.leftMargin + " r " + flickable.rightMargin
        }
        DebugLabel {
            text: "Content w " +  flickable.contentWidth + " h " + flickable.contentHeight + " x " + flickable.contentX + " y " + flickable.contentY
        }
        DebugLabel {
            text: "Item iw " + flickable.implicitContentWidth + " ih " + flickable.implicitContentWidth + " interactive " + flickable.interactive
        }
        DebugLabel {
            text: "Drag	detector horizontal " + flickable._dragDetector.horizontalDragUnused + " vertical " + flickable._dragDetector.verticalDragUnused
        }
        DebugLabel {
            text: flickable.zoom !== undefined ? "Zoom " + flickable.zoom.toFixed(1) + " minimum " + flickable.minimumZoom.toFixed(1) + " fitted " + flickable.fittedZoom : ""
        }
        DebugLabel {
            text: editor ? "Crop w " + editor.width + " h " + editor.height + " x " + editor.x + " y " + editor.y : ""
        }
        DebugLabel {
            text: flickable.baseRotation !== undefined ? "Rotation base " + flickable.baseRotation + " image " + flickable.imageRotation : ""
        }
        DebugLabel {
            text: flickable.orientation !== undefined ? "Orientation " + flickable.orientation + " transpose " + flickable.transpose : ""
        }
        DebugLabel {
            text: metadata ? "Orientation meta " + metadata.orientation + " orientation " + flickable.orientation : ""
        }
    }
}
