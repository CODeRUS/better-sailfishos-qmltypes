import QtQuick 2.0
import Sailfish.Silica 1.0

Grid {
    id: grid

    property real statusBarHeight: Theme.paddingMedium + Theme.paddingSmall + Theme.iconSizeExtraSmall
    readonly property real minimumHeight: _pageHeight - statusBarHeight - ((_largeScreen ? 5 : 3) * Theme.paddingLarge)
    readonly property real maximumWidth: parent.width - 2*Theme.paddingLarge
    property size coverSize: Theme.coverSizeLarge

    readonly property int smallColumns: (maximumWidth + spacing) / (Theme.coverSizeSmall.width + spacing)
    readonly property int largeColumns: (maximumWidth + spacing) / (Theme.coverSizeLarge.width + spacing)
    readonly property int largeRows: minimumHeight / Theme.coverSizeLarge.height

    property int baseY: _largeScreen
                        ? (_pageHeight > parent.width ? statusBarHeight + rowSpacing : Theme.paddingLarge * 5)
                        : statusBarHeight + Theme._homePageMargin

    property Item _page
    property int _pageHeight: _page ? _page.height : Screen.height
    readonly property bool _largeScreen: Screen.sizeCategory >= Screen.Large

    Component.onCompleted: {
        var parentItem = grid.parent
        while (parentItem) {
            if (parentItem.hasOwnProperty("__silica_page")) {
                _page = parentItem
                return
            }
            parentItem = parentItem.parent
        }
    }

    x: Math.floor((parent.width - (coverSize.width + spacing) * columns + spacing)/2)
    width: (coverSize.width + spacing) * columns - spacing
    spacing: Math.floor(_largeScreen ? Theme.paddingLarge * 3.333 : Theme.paddingLarge)

    // disclaimer! sailfish-silica/lib/silicatheme.cpp maximum cover size calculations rely on landscape tablet switcher
    // vertical margins to stay intact (switcherWrapper.y = Theme.paddingLarge * 5, rowSpacing = Theme.paddingLarge * 3.333)
    rowSpacing: _largeScreen && _pageHeight > parent.width
                        ? Math.ceil((_pageHeight - statusBarHeight - largeRows*Theme.coverSizeLarge.height) / (largeRows+1)) : spacing
}
