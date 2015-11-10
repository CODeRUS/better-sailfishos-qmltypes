import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Lipstick 1.0
import com.jolla.settings 1.0

// provides the grid layout. The delegate must be provided, i.e. a LauncherGridItem
SilicaGridView {
    id: gridView

    property real minimumDelegateSize: Theme.iconSizeLauncher
    property real pageHeight: parent.height
    // The multipliers below for Large screens are magic. They look good on Jolla tablet.
    property real minimumCellWidth: Screen.sizeCategory >= Screen.Large ? Theme.itemSizeExtraLarge * 1.6 : Theme.itemSizeExtraLarge
    // phone reference row height: 960 / 6
    property real minimumCellHeight: Screen.sizeCategory >= Screen.Large ? Theme.itemSizeExtraLarge * 1.6 : Theme.pixelRatio * 160
    property int columnCount: Math.floor(parent.width / minimumCellWidth)
    // reference row height: 960 / 6
    property int rowCount: Math.floor(pageHeight / minimumCellHeight)
    property int horizontalMargin: Screen.sizeCategory >= Screen.Large ? 6 * Theme.paddingLarge : Theme.paddingLarge
    property int initialCellWidth: (parent.width - 2*horizontalMargin) / columnCount

    anchors.horizontalCenter: parent.horizontalCenter

    cellWidth: Math.floor(initialCellWidth + (initialCellWidth - minimumDelegateSize) / (columnCount - 1))
    cellHeight: Math.round(pageHeight / rowCount)

    width: cellWidth * columnCount
    height: parent.height

    VerticalScrollDecorator {
        anchors.rightMargin: -(gridView.parent.width - gridView.width)/2
    }

    model: ApplicationsModel
}
