import QtQuick 2.1
import Sailfish.Silica 1.0
import Sailfish.Secrets.Ui 1.0
import Sailfish.Crypto 1.0
import Sailfish.FileManager 1.0
import Sailfish.Gallery 1.0

Dialog {
    id: root

    property string keySource
    property alias keyName: keyNameField.text

    canAccept: keyName.length > 0

    SilicaFlickable {
        contentHeight: column.height
        bottomMargin: Theme.paddingLarge
        anchors.fill: parent

        Column {
            id: column

            width: parent.width
            DialogHeader {
                //% "Import"
                acceptText: qsTrId("secrets_ui-bt-import")
                //% "Import key"
                title: qsTrId("secrets_ui-he-import_key")
            }

            FileInfoItem {
                fileInfo: FileInfo { source: root.keySource }
            }

            TextField {
                id: keyNameField

                property bool validInput: text.length > 0

                onActiveFocusChanged: if (!activeFocus && !validInput) errorHighlight = true
                onValidInputChanged: if (validInput) errorHighlight = false

                focus: true
                width: parent.width
                //% "Key name"
                label: qsTrId("secrets_ui-la-key_name")
                placeholderText: label
                text: {
                    if (keySource.length > 0) {
                        var index = keySource.lastIndexOf('/')
                        if (index >= 0) return keySource.slice(index+1)
                    }
                    return ""
                }

                EnterKey.enabled: root.canAccept
                EnterKey.iconSource: "image://theme/icon-m-enter-accept"
                EnterKey.onClicked: root.accept()
            }
        }
    }
}
