import QtQuick 2.0
import Sailfish.Silica 1.0

DialogHeader {
    //: Next page
    //% "Next"
    property string nextPageText: qsTrId("startupwizard-he-next_page")

    //: Previous page
    //% "Previous"
    property string previousPageText: qsTrId("startupwizard-he-previous_page")

    acceptText: nextPageText
    cancelText: previousPageText
}
