import QtQuick 2.2
import Sailfish.Silica 1.0
import Sailfish.Crypto 1.0 as Crypto
import Sailfish.Secrets 1.0 as Secrets
import Sailfish.Secrets.Ui 1.0

Column {
    id: collectionKeysView

    property alias cryptoManager: collectionKeysModel.cryptoManager
    property alias storagePluginName: collectionKeysModel.storagePluginName
    property alias collectionName: collectionKeysModel.collectionName
    property QtObject secretManager

    signal collectionKeysRequestCompleted(int errorCode)

    function requestKeysFromCollection() {
        collectionKeysModel.requestKeysFromCollection()
    }

    // Backup of translation ids

    //% "Show keys"
    property string showKeys: qsTrId("secrets_ui-bt-show_keys")

    //% "Fetching keys"
    property string fetchingKeys: qsTrId("secrets_ui-la-fetching_keys")

    //% "Fetching keys failed"
    property string fetchingFailed: qsTrId("secrets_ui-la-fetching_keys_failed")

    InfoLabel {
        id: label
        opacity: text && (keyManagerLoader.item && (!keyManagerLoader.item.keyManager.busy || !keyManagerLoader.active)) ? 1.0 : 0.0
        Behavior on opacity {
            FadeAnimation {}
        }

        font.pixelSize: Theme.fontSizeLarge
        height: opacity * implicitHeight
        text: {
            if (collectionKeysModel.count == 0) {
                //% "No keys"
                return qsTrId("secrets_ui-la-no_keys")
            }
            return ""
        }
    }

    Item {
        width: 1
        height: Theme.paddingLarge
        visible: label.text
    }

    Repeater {
        id: keysRepeater
        width: parent.width

        model: CollectionKeysModel {
            id: collectionKeysModel
            onRequestKeysFromCollectionCompleted: collectionKeysView.collectionKeysRequestCompleted(errorCode)

            onStorageError: root.storageError(error)
            onError: root.error(errorCode)

            onCollectionNameChanged: refreshModelData()
        }

        delegate: KeyIdentifierItem {
            text: model.name
            width: parent.width
            enabled: !keyManagerLoader.active || (keyManagerLoader.item && !keyManagerLoader.item.keyManager.busy)

            opacity: enabled ? 1.0 : Theme.opacityLow
            Behavior on opacity {
                FadeAnimation {}
            }

            onClicked: {
                if (root.openMenuOnClick) {
                    openMenu()
                }

                root.clicked(model.object, Crypto.CryptoManager.DigestSha256)
            }

            onRemove: collectionKeysModel.removeAt(model.index)
        }
    }

    KeyManagerLoader {
        id: keyManagerLoader

        active: root.editMode
        collectionKeysModel: collectionKeysModel
        cryptoManager: collectionKeysView.cryptoManager
        secretManager: collectionKeysView.secretManager
        storagePluginName: collectionKeysView.storagePluginName
        collectionName: collectionKeysView.collectionName

        onGenerated: requestKeysFromCollection()
        onImported: requestKeysFromCollection()
    }
}
