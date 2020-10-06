import QtQuick 2.0
import Sailfish.Silica 1.0

DetailItem {
    readonly property bool onLeft: Positioner.index % 2 == 0
    width: parent.width / parent.columns
    leftMargin: onLeft || isPortrait ? Theme.horizontalPageMargin : Theme.paddingMedium
    rightMargin: !onLeft || isPortrait ? Theme.horizontalPageMargin : Theme.paddingMedium
}