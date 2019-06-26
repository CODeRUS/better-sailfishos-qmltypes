import QtQuick 2.0
import Sailfish.Silica 1.0
import org.nemomobile.systemsettings 1.0
import Sailfish.Settings.Networking 1.0

Dialog {
    id: root

    property string title
    property var connection
    property bool newConnection

    acceptDestinationAction: PageStackAction.Pop
}
