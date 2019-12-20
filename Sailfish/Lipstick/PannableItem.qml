import QtQuick 2.2
import Sailfish.Silica 1.0
import Sailfish.Silica.private 1.0 as Private
import Sailfish.Lipstick 1.0

PixelAlignedFocusScope {
    id: homescreenItem

    property Item leftItem
    property Item rightItem

    readonly property bool isCurrentItem: Private.Slide.isCurrent
    readonly property bool exposed: Private.Slide.isExposed
    readonly property real offset: Private.Slide.offset

    property var cleanup

    Private.Slide.backward: leftItem
    Private.Slide.forward: rightItem

    Private.Slide.onCleanup: {
        if (cleanup) {
            cleanup()
        }
    }
}
