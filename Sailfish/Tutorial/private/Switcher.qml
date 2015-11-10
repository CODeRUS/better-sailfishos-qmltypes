import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    property int horizontalMargin: (Screen.sizeCategory >= Screen.Large ? 133 : 25) * xScale
    property int verticalMargin: (Screen.sizeCategory >= Screen.Large ? 195 : 75) * yScale
    property alias horizontalSpacing: grid.columnSpacing
    property alias verticalSpacing: grid.rowSpacing

    Grid {
        id: grid

        anchors {
            top: parent.top
            topMargin: verticalMargin
            bottom: parent.bottom
            bottomMargin: verticalMargin
            left: parent.left
            leftMargin: horizontalMargin
            right: parent.right
            rightMargin: horizontalMargin
        }

        columnSpacing: (Screen.sizeCategory >= Screen.Large ? 107 : 41) * xScale
        rowSpacing: (Screen.sizeCategory >= Screen.Large ? 107 : 41) * yScale

        rows: 2
        columns: 3

        Repeater {
            model: ["people", "clock", "camera", "settings", "browser", "gallery"]

            Image {
                width: (Screen.sizeCategory >= Screen.Large ? 352 : 136) * xScale
                height: (Screen.sizeCategory >= Screen.Large ? 562 : 218) * yScale
                sourceSize.width: width
                sourceSize.height: height

                source: Screen.sizeCategory >= Screen.Large
                        ? Qt.resolvedUrl("file:///usr/share/sailfish-tutorial/graphics/tutorial-tablet-" + modelData + "-cover.png")
                        : Qt.resolvedUrl("file:///usr/share/sailfish-tutorial/graphics/tutorial-phone-" + modelData + "-cover.png")
            }
        }
    }
}
