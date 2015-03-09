import QtQuick 2.0
import Sailfish.Silica 1.0

Label {
    wrapMode: Text.WordWrap
    font.pixelSize: Theme.fontSizeExtraLarge
    color: Theme.highlightColor
    visible: root.isNewAccount

    //: Indicates a user account has been added
    //% "Account added"
    text: qsTrId("accounts-he-account_added")
}
