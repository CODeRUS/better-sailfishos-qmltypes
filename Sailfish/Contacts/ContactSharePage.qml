import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.TransferEngine 1.0

Page {
    id: page

    property variant content

    ShareMethodList {
        id: methodList

        content: page.content
        filter: "text/vcard"
        anchors.fill: parent
        header: PageHeader {
            //% "Share contact"
            title: qsTrId("components_contacts-he-share_contact")
        }

        ViewPlaceholder {
            enabled: methodList.count == 0 && methodList.model.ready
            //: Empty state for share method selection page
            //% "No sharing accounts available. You can add accounts in settings"
            text: qsTrId("components_contacts-la-no-share-methods")
        }
        VerticalScrollDecorator {}
    }
}
