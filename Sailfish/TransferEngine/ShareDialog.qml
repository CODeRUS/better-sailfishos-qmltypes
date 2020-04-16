import QtQuick 2.0
import Sailfish.Silica 1.0

Dialog {
    id: root

    property url source
    property var content: ({})
    property string methodId
    property string displayName
    property int accountId
    property string accountName
    property alias shareEndDestination: root.acceptDestinationAction

    acceptDestinationAction: PageStackAction.Pop
    allowedOrientations: Orientation.All
}
