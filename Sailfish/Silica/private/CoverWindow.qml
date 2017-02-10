
import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Silica.private 1.0 as Private
import org.nemomobile.thumbnailer 1.0

Private.CoverWindow {
    id: coverWindow
    title: "_CoverWindow"
    width: (window._transpose && !Config.wayland) ? Theme.coverSizeLarge.height : Theme.coverSizeLarge.width
    height: (window._transpose && !Config.wayland) ? Theme.coverSizeLarge.width : Theme.coverSizeLarge.height

    Thumbnail.maxCost: Theme.coverSizeLarge.width * Theme.coverSizeLarge.height * 3

    mainWindow: window

    Component.onCompleted: {
        contentItem.width = coverWindow.width
        contentItem.height = coverWindow.height
        window._setCover(coverWindow)
    }
}
