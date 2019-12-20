import QtQuick 2.2
import Sailfish.Silica 1.0
import Sailfish.Crypto 1.0
import Sailfish.Secrets 1.0 as Secrets
import Sailfish.Secrets.Ui 1.0

Column {
    id: root

    property bool populated
    property bool editMode
    property bool openMenuOnClick

    property QtObject cryptoManager
    property QtObject secretManager

    signal pluginLockCodeRequest(string pluginName, int requestType)
    signal clicked(var key, int digest)
    signal storageError(int errorCode)
    signal error(int errorCode)

    width: parent.width
    SectionHeader { text: model.displayName }

    Loader {
        width: parent.width
        active: populated
        height: status === Loader.Ready ? implicitHeight : placeholder.height + 2 * Theme.paddingLarge

        BusyPlaceholder {
            id: placeholder
            anchors.verticalCenter: parent.verticalCenter
            active: !populated
            text: !populated ?
                      //% "Loading"
                      qsTrId("secrets_ui-la-loading") :
                      //% "Storage not available"
                      qsTrId("secrets_ui-la-storage_not_available")
        }

        sourceComponent: Column {
            readonly property bool pluginLocked: !(model.statusFlags & Secrets.PluginInfo.PluginUnlocked)
            onPluginLockedChanged: {
                if (!pluginLocked) {
                    collectionsView.refreshCollections()
                }
            }

            width: parent.width

            Row {
                x: Theme.horizontalPageMargin
                width: parent.width - 2*x
                spacing: Theme.paddingSmall
                Label {
                    id: nameLabel
                    color: Theme.secondaryHighlightColor
                    font.pixelSize: Theme.fontSizeSmall
                    //% "Name"
                    text: qsTrId("secrets_ui-la-name")
                }

                Label {
                    width: parent.width - nameLabel.width - parent.spacing
                    color: Theme.highlightColor
                    font.pixelSize: Theme.fontSizeSmall
                    wrapMode: Text.Wrap
                    text: model.name
                }
            }

            Item {
                width: 1
                height: Theme.paddingMedium
                visible: supportLockingLabel.visible
            }

            Label {
                id: supportLockingLabel
                visible: (model.statusFlags & Secrets.PluginInfo.PluginSupportsLocking)
                wrapMode: Text.Wrap
                font.pixelSize: Theme.fontSizeSmall
                x: Theme.horizontalPageMargin
                width: parent.width - 2*x
                color: Theme.secondaryHighlightColor

                //% "Protected with lock code"
                text: qsTrId("secrets_ui-la-protected_with_lock_code")
            }

            Item {
                width: 1
                height: Theme.paddingLarge
                visible: supportLockingLabel.visible
            }

            Button {
                text: pluginLocked ?
                          //% "Unlock"
                          qsTrId("secrets_ui-bt-unlock_plugin") :
                          //% "Change lock code"
                          qsTrId("secrets_ui-bt-change_lock_code")

                preferredWidth: Theme.buttonWidthMedium
                anchors.horizontalCenter: parent.horizontalCenter
                visible: supportLockingLabel.visible || pluginLocked
                onClicked: pluginLockCodeRequest(model.name, pluginLocked ? Secrets.LockCodeRequest.ProvideLockCode
                                                                          : Secrets.LockCodeRequest.ModifyLockCode)
            }

            Item {
                width: 1
                height: Theme.paddingLarge
                visible: collectionsView.visible
            }

            CollectionsView {
                id: collectionsView
                width: parent.width
                cryptoManager: root.cryptoManager
                secretManager: root.secretManager
                storagePluginName: model.name
                visible: storagePluginName.length && !pluginLocked

                Component.onCompleted: {
                    if (!pluginLocked) refreshCollections()
                }
            }

            KeyManagerLoader {
                active: !pluginLocked && collectionsView.collectionsPopulated && collectionsView.collectionsCount == 0
                cryptoManager: root.cryptoManager
                secretManager: root.secretManager
                storagePluginName: model.name

                onGenerated: collectionsView.refreshCollections()
                onImported: collectionsView.refreshCollections()
            }
        }
    }
}
