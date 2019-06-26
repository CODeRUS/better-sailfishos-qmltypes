import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.TransferEngine 1.0

SharePage {
    id: page

    mimeType: "text/vcard"
    //% "Share contact"
    header: qsTrId("components_contacts-he-share_contact")
    serviceFilter: ["e-mail"]
}
