import QtQuick 2.0
import Sailfish.Silica 1.0

Column {
    id: self

    property bool enabled
    property alias text: messageField.text
    property alias contentMargin: messageField.textMargin

    signal clicked

    width: parent.width
    opacity: enabled ? 1.0 : 0.0

    Behavior on opacity { FadeAnimation {} }

    TextField {
        id: messageField
        width: parent.width
        //% "Description"
        label: qsTrId("vault-la-description")
        //% "Backup info here"
        placeholderText: qsTrId("vault-ph-backup_info_here")
        enabled: self.enabled
        EnterKey.iconSource: text.length > 0 ? "image://theme/icon-m-enter-accept"
                                             : "image://theme/icon-m-enter-close"
        EnterKey.onClicked: {
            focus = false
            if (text.length > 0) {
                self.clicked()
            }
        }
    }

    Item { width: 1; height: Theme.paddingLarge }

    Button {
        //% "Create"
        text: qsTrId("vault-bt-create")
        enabled: self.enabled
        anchors.horizontalCenter: parent.horizontalCenter
        onClicked: self.clicked()
    }

    Item { width: 1; height: Theme.paddingLarge }
}
