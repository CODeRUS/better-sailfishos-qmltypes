import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Accounts 1.0
import Sailfish.Vault 1.0

ListModel {
    id: root

    property var backupSource // int (account id) or string (dir path)
    property bool loading
    property bool error
    property bool active: true

    property var _cloudListingCache: ({})

    function _prepareToLoad() {
        error = false
        loading = true
        clear()
    }

    function _loaded(ok) {
        error = !ok
        loading = false
    }

    onBackupSourceChanged: {
        if (!active) {
            return
        }
        if (typeof backupSource == "number") {
            _loadFromCloudAccount(backupSource)
        } else if (typeof backupSource == "string") {
            _loadFromFilePath(backupSource)
        } else {
            _cloudListingCache = {}
            _prepareToLoad()
            _loaded(true)
        }
    }

    function _loadFromFilePath(dirPath) {
        _prepareToLoad()
        if (dirPath.length > 0) {
            var files = _backupUtils.sortedBackupFileInfo(dirPath)
            for (var i=0; i<files.length; i++) {
                append(files[i])
            }
        }
        _loaded(true)
    }

    function _loadFromCloudAccount(sourceAccountId) {
        _prepareToLoad()
        if (sourceAccountId > 0) {
            if (_cloudListingCache && _cloudListingCache[sourceAccountId] !== undefined) {
                var fileInfoList = _cloudListingCache[sourceAccountId]
                for (var i=0; i<fileInfoList.length; i++) {
                    append(fileInfoList[i])
                }
            } else {
                _cloudSync.resetState()
                _cloudSync.requestListing(sourceAccountId)
                return
            }
        }
        _loaded(true)
    }

    property BackupUtils _backupUtils: BackupUtils {}

    property CloudBackupSyncTrigger _cloudSync: CloudBackupSyncTrigger {
        onRequestedListing: {
            if (root.backupSource === accountId) {
                clear()
                if (listing.length > 0) {
                    var fileNames = []
                    var i
                    for (i=0; i<listing.length; i++) {
                        var data = listing[i]
                        if (data.name) {
                            if (data.parent) {
                                fileNames.push(data.parent + '/' + data.name)
                            } else {
                                fileNames.push(data.name)
                            }
                        }
                    }
                    var fileInfoList = _backupUtils.sortedBackupFileInfo(fileNames)
                    _cloudListingCache[accountId] = fileInfoList
                    for (i=0; i<fileInfoList.length; i++) {
                        append(fileInfoList[i])
                    }
                } else {
                    _cloudListingCache[accountId] = []
                }
                root._loaded(true)
            }
        }

        onRequestListingFailed: {
            if (root.backupSource === accountId) {
                console.log("Unable to get listing for account", accountId, ":", message)
                root._loaded(false)
            }
        }
    }
}
