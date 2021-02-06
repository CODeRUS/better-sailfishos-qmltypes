/****************************************************************************************
**
** Copyright (c) 2013 - 2019 Jolla Ltd.
** Copyright (c) 2020 Open Mobile Platform LLC.
**
** License: Proprietary
**
****************************************************************************************/

import QtQuick 2.6
import Sailfish.Silica 1.0
import Sailfish.Vault 1.0
import MeeGo.Connman 0.2
import Nemo.Configuration 1.0
import com.jolla.settings.accounts 1.0

Column {
    id: root
    width: parent ? parent.width : Screen.width

    readonly property bool selectionValid: (cloudAccountId > 0 || memoryCardPath.length > 0)
                                            && _errorText.length === 0

    property int cloudAccountId
    property string memoryCardPath
    property bool selectedStorageMounted: true
    property bool selectedStorageLocked

    property real leftMargin: Theme.horizontalPageMargin
    property real rightMargin: Theme.horizontalPageMargin

    property var storageListModel

    readonly property string _localBackupUnitsText: storageListModel.localBackupUnits.join(Format.listSeparator)
    readonly property string _cloudBackupUnitsText: storageListModel.cloudBackupUnits.join(Format.listSeparator)

    readonly property string _errorText: {
        if (_memoryCardError.length > 0) {
            return _memoryCardError
        } else if (cloudAccountId > 0
                   && networkManagerFactory.instance.state !== ""
                   && networkManagerFactory.instance.state !== "online") {
            return BackupUtils.cloudConnectErrorText
        }
        return ""
    }

    property string _memoryCardError

    function activeItem() {
        return storageListModel.get(storageCombo.currentIndex)
    }

    function _matchesComboIndex(index, accountIdOrPath) {
        var data = storageListModel.get(index)
        return (typeof accountIdOrPath === 'number' && data.accountId === accountIdOrPath)
                    || data.devPath === accountIdOrPath
    }

    function _delegateLoaded(index) {
        if (lastSelectedStorage.value == null) {
            storageCombo.currentIndex = 0
            root._update()
        } else if (_matchesComboIndex(index, lastSelectedStorage.value)) {
            storageCombo.currentIndex = index
            root._update()
        }
    }

    function _update() {
        if (!root.storageListModel.ready || storageRepeater.count === 0) {
            return
        }

        if (storageCombo.currentIndex < 0) {
            storageCombo.currentIndex = 0
        }

        var data = activeItem()
        if (data.type === storageListModel.storageTypeMemoryCard) {
            selectedStorageMounted = data.path.length > 0
            selectedStorageLocked = data.deviceStatus === storageListModel.storageLocked
            cloudAccountId = 0
            _memoryCardError = data.latestBackupInfo.error || ""
            memoryCardPath = _memoryCardError.length ? "" : data.path
        } else if (data.type === storageListModel.storageTypeCloud) {
            selectedStorageMounted = true
            selectedStorageLocked = false
            cloudAccountId = data.accountId
            _memoryCardError = ""
            memoryCardPath = ""
        } else {
            console.warn("Unrecognized storage type!")
        }
    }

    NetworkManagerFactory {
        id: networkManagerFactory
    }

    Connections {
        target: root.storageListModel

        onMemoryCardMounted: root._update()
        onReadyChanged: root._update()
    }

    ComboBox {
        id: storageCombo

        leftMargin: root.leftMargin
        rightMargin: root.rightMargin

        //: Displayed before the list of items allowing the user to choose where data will be backed up to
        //% "Manually back up to"
        label: qsTrId("vault-la-manually_back_up_to")
        automaticSelection: false
        currentIndex: -1
        enabled: root.enabled

        menu: ContextMenu {
            id: storageMenu

            closeOnActivation: false

            Repeater {
                id: storageRepeater

                model: root.storageListModel

                // If model has changed after currentIndex is set, need to refresh the selection details.
                onCountChanged: root._update()

                MenuItem {
                    text: model.name

                    onClicked: {
                        if (model.accountId > 0) {
                            lastSelectedStorage.value = model.accountId
                        } else {
                            lastSelectedStorage.value = model.devPath
                        }

                        storageCombo.currentIndex = index
                        root._update()
                        storageMenu.close()
                    }

                    Component.onCompleted: root._delegateLoaded(model.index)
                }
            }
        }

        descriptionColor: root._errorText.length > 0
               ? Theme.errorColor
               : (highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor)

        description: {
            if (root._errorText.length > 0) {
                return root._errorText
            }

            return root.cloudAccountId > 0
                    ? BackupUtils.cloudBackupDescription(root._cloudBackupUnitsText)
                    : BackupUtils.localBackupDescription(root._localBackupUnitsText)
        }
    }

    ConfigurationValue {
        id: lastSelectedStorage

        key: "/sailfish/backup/last_selected_storage"
    }
}
