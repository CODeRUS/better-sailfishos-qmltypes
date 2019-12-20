import QtQuick 2.2
import Sailfish.Silica 1.0
import Sailfish.Crypto 1.0
import Sailfish.Secrets.Ui 1.0

Loader {
    id: keyManagerLoader

    property QtObject collectionKeysModel
    property QtObject cryptoManager
    property QtObject secretManager
    property string storagePluginName
    property string collectionName: defaultKeyCollectionName

    signal generated
    signal imported

    width: parent.width
    sourceComponent: Column {
        property alias keyManager: keyManager

        spacing: Theme.paddingLarge
        width: parent.width

        Item {
            width: 1
            height: Theme.paddingLarge
            visible: collectionKeysModel && collectionKeysModel.count > 0
        }

        Button {
            //% "Generate new key"
            text: qsTrId("secrets_ui-me-generate_new_key")
            enabled: !keyManager.busy
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: {
                var obj = pageStack.animatorPush("Sailfish.Secrets.Ui.KeyGenerationDialog")
                obj.pageCompleted.connect(function(dialog) {
                    dialog.accepted.connect(function() {
                        var keyTemplate = cryptoManager.constructKey()
                        var keyAlgorithm = dialog.keyAlgorithm
                        var keyPairGenerationParams

                        if (keyAlgorithm === CryptoManager.AlgorithmRsa) {
                            keyPairGenerationParams = cryptoManager.constructRsaKeygenParams()
                        } else if (keyAlgorithm === CryptoManager.AlgorithmEc) {
                            keyPairGenerationParams = cryptoManager.constructEcKeygenParams()
                        }

                        keyTemplate.algorithm = keyAlgorithm
                        keyTemplate.name = dialog.keyName

                        keyManager.generateKey(keyTemplate, keyPairGenerationParams)
                    })
                })
            }
        }

        Button {
            //% "Import key"
            text: qsTrId("secrets_ui-me-import_key")
            enabled: !keyManager.busy
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: {
                var obj = pageStack.animatorPush("Sailfish.Pickers.FilePickerPage", {
                                                     nameFilters: [ '*.pem' ],
                                                     popOnSelection: false
                                                 })
                obj.pageCompleted.connect(function(picker) {
                    picker.selectedContentPropertiesChanged.connect(function() {
                        var obj = pageStack.animatorPush("Sailfish.Secrets.Ui.KeyImportDialog", {
                                                             keySource: picker.selectedContentProperties['filePath'],
                                                             acceptDestination: page,
                                                             acceptDestinationAction: PageStackAction.Pop
                                                         })
                        obj.pageCompleted.connect(function(dialog) {
                            dialog.accepted.connect(function() {
                                keyManager.importKey(dialog.keyName, dialog.keySource)
                            })
                        })
                    })
                })
            }
        }

        BusyPlaceholder {
            id: busyPlaceholder
            spacing: Theme.paddingMedium
            active: keyManager.busy
            height: opacity * implicitHeight
            width: parent.width
            text: {
                if (keyManager.status == KeyManager.Generating) {
                    //% "Generating key, please be patient"
                    return qsTrId("secrets_ui-la_generating_key_busy_state")
                }

                //% "This might take a while"
                return qsTrId("secrets_ui-la_generic_key_busy")
            }
        }

        Item {
            width: 1
            height: Theme.paddingLarge
            visible: collectionKeysModel && collectionKeysModel.count > 0
        }

        KeyManager {
            id: keyManager
            cryptoManager: keyManagerLoader.cryptoManager
            secretManager: keyManagerLoader.secretManager
            pluginName: keyManagerLoader.storagePluginName
            collectionName: keyManagerLoader.collectionName

            onGenerated: keyManagerLoader.generated()
            onImported: keyManagerLoader.imported()

            onStorageError: root.storageError(error)
            onError: root.error(errorCode)
        }
    }
}
