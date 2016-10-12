import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.TransferEngine 1.0

Page {
    property alias url: shareMethodList.source
    property alias mimeType: shareMethodList.filter

    ShareMethodList {
        id: shareMethodList

        anchors.fill: parent
        header: PageHeader {
            //% "Share"
            title: qsTrId("filemanager-he-share")
        }
    }
}
