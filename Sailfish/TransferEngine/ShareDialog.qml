import QtQuick 2.0
import Sailfish.Silica 1.0

Dialog {
    property url source
    property variant content: ({})
    property string methodId
    property string displayName
    property int accountId
    property string accountName

    allowedOrientations: Orientation.All
}
