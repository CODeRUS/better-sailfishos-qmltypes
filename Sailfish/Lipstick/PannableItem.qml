import QtQuick 2.2
import Sailfish.Silica 1.0
import Sailfish.Lipstick 1.0

PixelAlignedItem {
    id: homescreenItem

    property Item leftItem
    property Item rightItem

    property bool isCurrentItem: parent.currentItem == homescreenItem
    property bool isTransitionItem: parent.alternateItem == homescreenItem

    property var cleanup
}
