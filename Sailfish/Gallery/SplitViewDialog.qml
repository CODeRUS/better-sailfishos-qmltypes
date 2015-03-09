import QtQuick 2.0
import Sailfish.Silica 1.0

Dialog {
    id: dialog

    // open and opened would shadow Dialog's opened signal and open function.
    property alias splitOpen: drawer.open
    property alias splitOpened: drawer.opened

    property alias backgroundItem: drawer.backgroundItem
    property alias background: drawer.background

    property alias foregroundItem: drawer.foregroundItem
    property alias foreground: drawer.foreground

    default property alias data: drawer.data

    backNavigation: drawer.open
    allowedOrientations: Orientation.All

    Drawer {
        id: drawer
        dock: dialog.orientation == Orientation.Portrait ? Dock.Top: Dock.Left
        hideOnMinimize: true
        anchors.fill: parent
    }
}
