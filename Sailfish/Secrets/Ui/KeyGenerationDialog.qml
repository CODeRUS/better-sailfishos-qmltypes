import QtQuick 2.1
import Sailfish.Silica 1.0
import Sailfish.Crypto 1.0

Dialog {
    id: dialog

    property alias keyName: keyNameTextField.text
    property alias keyAlgorithm: keyAlgorithmComboBox.currentAlgorithm

    canAccept: keyName.length > 0

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height
        bottomMargin: Theme.paddingLarge

        Column {
            id: column
            width: parent.width

            DialogHeader {
                //% "Generate new key"
                title: qsTrId("secrets_ui-he-generate_new_key")
            }

            TextField {
                id: keyNameTextField
                width: parent.width
                //% "Key name"
                label: qsTrId("secrets_ui-la-key_name")
                errorHighlight: !focus && text.length === 0
                placeholderText: label
                focus: true

                EnterKey.iconSource: "image://theme/icon-m-enter-close"
                EnterKey.onClicked: {
                    focus = false
                }
            }

            ComboBox {
                id: keyAlgorithmComboBox
                width: parent.width
                //% "Key type"
                label: qsTrId("secrets_ui-la-key_type")
                property int currentAlgorithm: currentItem.keyAlgorithm

                menu: ContextMenu {
                    MenuItem {
                        //% "RSA"
                        text: qsTrId("secrets_ui-me-keytype_rsa")
                        property int keyAlgorithm: CryptoManager.AlgorithmRsa
                    }
                    MenuItem {
                        //% "Elliptic curve"
                        text: qsTrId("secrets_ui-me-keytype_ec")
                        property int keyAlgorithm: CryptoManager.AlgorithmEc
                    }
                }
            }
        }

        VerticalScrollDecorator {}
    }
}
