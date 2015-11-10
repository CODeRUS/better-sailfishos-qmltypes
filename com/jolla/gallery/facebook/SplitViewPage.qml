import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: page

    property alias open: drawer.open
    property alias opened: drawer.opened

    property alias background: drawer.background
    property alias foreground: drawer.foreground

    default property alias data: drawer.data

    backNavigation: drawer.open

    Drawer {
        id: drawer
        dock: page.orientation == Orientation.Portrait ? Dock.Top: Dock.Left
        hideOnMinimize: true
        anchors.fill: parent
    }
}
