import QtQuick 2.4
import Sailfish.Silica 1.0
import "Util.js" as Util

SilicaGridView {
    id: root

    property int pageHeight: height
    property int horizontalMargin: largeScreen ? (fullHdPortraitWidth ? 3 : 6) * Theme.paddingLarge : Theme._homePageMargin
    property int launcherItemSpacing: Theme.paddingSmall
    property real minimumDelegateSize: Theme.iconSizeLauncher
    property bool isPortrait: !_page || _page.isPortrait
    property Item _page: Util.findPage(root)

    // For wider than 16:9 full hd
    // FIXME: See Bug #43014
    readonly property bool fullHdPortraitWidth: Screen.width == 1080

    // The multipliers below for Large screens are magic. They look good on Jolla tablet.
    property real minimumCellWidth: largeScreen ? (fullHdPortraitWidth ? 1.2 : 1.6) * Theme.itemSizeExtraLarge
                                                  // leave room for launcher icon and paddings
                                                : Theme.iconSizeLauncher + Theme.paddingLarge + Theme.paddingMedium
    // phone reference row height: 960 / 6
    property real minimumCellHeight: largeScreen ? (fullHdPortraitWidth ? 1.2 : 1.6) * Theme.itemSizeExtraLarge
                                                   // leave room for launcher icon, app title, spacing between, and paddings around
                                                 : Theme.iconSizeLauncher + Theme.paddingLarge + Theme.paddingMedium
                                                   + launcherLabelMetrics.height + launcherItemSpacing

    property alias launcherLabelFontSize: launcherLabelMetrics.font.pixelSize
    property int rows: Math.max(isPortrait ? 6 : 3, Math.floor(pageHeight / minimumCellHeight))
    property int columns: Math.max(isPortrait ? 4 : 6, Math.floor(parent.width / minimumCellWidth))

    property int initialCellWidth: (parent.width - 2*horizontalMargin) / columns
    readonly property bool largeScreen: Screen.sizeCategory >= Screen.Large

    cellWidth: Math.floor(initialCellWidth + (initialCellWidth - minimumDelegateSize) / (columns - 1))
    cellHeight: Math.round(pageHeight / rows)

    width: cellWidth * columns
    anchors.horizontalCenter: parent.horizontalCenter

    FontMetrics {
        id: launcherLabelMetrics
        font.pixelSize: Theme.fontSizeTiny
    }
}
