import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Vault 1.0
import Sailfish.Accounts 1.0

QtObject {
    id: root

    property string currentUnit
    property real progress
    property UnitListModel unitListModel

    property bool running: syncing
                           || (backupRestore.status != SimpleBackupRestore.Idle
                               && backupRestore.status != SimpleBackupRestore.Finished)
    property bool canceling: backupRestore.status == SimpleBackupRestore.Canceling
    property bool syncing

    signal done()
    signal error(string errorMainText, string errorDetailText)
    signal statusUpdate(string statusText)

    function backupToCloud(accountId, units) {
        if (!accountId || accountId < 0) {
            console.log("backupToCloud(): invalid accountId!")
            return
        }
        var fileName = _backupUtils.newBackupFileName(BackupUtils.TarGzipArchive)
        _reset(SimpleBackupRestore.Backup, units || _findUnits(true), fileName)
        _cloudAccountId = accountId
        _cloudLocalSyncDir = _backupUtils.privilegedBackupDirectory("cloud")
        _initProgress()

        backupRestore.backup(_units, _cloudLocalSyncDir + '/' + fileName)
    }

    function backupToDir(dirPath, units) {
        if (!dirPath) {
            console.log("backupToDir(): invalid dirPath!")
            return
        }
        var fileName = _backupUtils.newBackupFileName(BackupUtils.TarArchive)
        _reset(SimpleBackupRestore.Backup, units || _findUnits(), fileName)
        _initProgress()

        backupRestore.backup(_units, _removeLastDirSeparator(dirPath) + '/' + fileName)
    }

    function restoreFromCloud(accountId, filePath, units) {
        if (!accountId || accountId < 0) {
            console.log("restoreFromCloud(): invalid accountId!")
            return
        }
        if (!filePath) {
            console.log("restoreFromCloud(): invalid filePath!")
            return
        }
        var fileName = ""
        var remoteDir = ""
        var dirSep = filePath.lastIndexOf('/')
        if (dirSep) {
            fileName = filePath.substr(dirSep + 1)
            remoteDir = filePath.substr(0, dirSep)
        } else {
            fileName = filePath
        }

        _reset(SimpleBackupRestore.Restore, units || _findUnits(true), fileName)
        _cloudAccountId = accountId
        _cloudLocalSyncDir = _backupUtils.privilegedBackupDirectory("cloud")
        _downloadedFilePath = _cloudLocalSyncDir + '/' + fileName
        _initProgress()

        cloudSync.resetState()
        if (cloudSync.downloadFromCloud(_cloudAccountId, _cloudLocalSyncDir, remoteDir, fileName)) {
            _logText("Triggered backup download from cloud account" + _cloudAccountId)
        } else {
            _handleAccountSyncSetupError()
        }
    }

    function restoreFromFile(filePath, units) {
        if (!filePath) {
            console.log("restoreFromFile(): invalid dirPath!")
            return
        }
        _reset(SimpleBackupRestore.Restore, units || _findUnits(), filePath)
        _initProgress()

        backupRestore.restore(_units, filePath)
    }

    function compressToCloud(srcDirPath, accountId, presetDateTime) {
        if (!srcDirPath) {
            console.log("compressToCloud(): invalid srcDirPath!")
            return
        }
        if (!accountId || accountId < 0) {
            console.log("compressToCloud(): invalid accountId!")
            return
        }
        if (!presetDateTime) {
            console.log("compressToCloud(): invalid presetDateTime!")
            return
        }
        var fileName = _backupUtils.newBackupFileName(BackupUtils.TarGzipArchive, presetDateTime)
        _reset(SimpleBackupRestore.Compress, [], fileName)
        _cloudAccountId = accountId
        _cloudLocalSyncDir = _backupUtils.privilegedBackupDirectory("cloud")
        _initProgress()

        backupRestore.compress(srcDirPath, _cloudLocalSyncDir + '/' + fileName)
    }

    function compressToDir(srcDirPath, destDirPath, presetDateTime) {
        if (!srcDirPath) {
            console.log("compressToDir(): invalid srcDirPath!")
            return
        }
        if (!presetDateTime) {
            console.log("compressToDir(): invalid presetDateTime!")
            return
        }
        var fileName = _backupUtils.newBackupFileName(BackupUtils.TarArchive, presetDateTime)
        _reset(SimpleBackupRestore.Compress, [], fileName)
        _initProgress()

        backupRestore.compress(srcDirPath, destDirPath + '/' + fileName)
    }

    function cancel() {
        if (syncing) {
            _logText("Syncing stage cannot be canceled!")
            return
        }
        return backupRestore.cancel()
    }

    function deleteOldBackups(dirPath) {
        // keep the two latest backups
        var fileInfos = _backupUtils.sortedBackupFileInfo(dirPath)
        for (var i=2; i<fileInfos.length; i++) {
            _logText("Deleting old backup file " + fileInfos[i].fileName)
            _backupUtils.removeFile(dirPath + '/' + fileInfos[i].fileName)
            _backupUtils.removeFile(backupRestore.defaultLogFilePath(fileInfos[i].fileName, _mode))
        }
    }

    // ====

    property int _mode
    property int _cloudAccountId
    property string _downloadedFilePath
    property string _cloudLocalSyncDir
    property var _units: []

    property int _currentStep
    property int _maxSteps

    function _reset(mode, units, fileNameOrPath) {
        _mode = mode
        _units = units
        backupRestore.initializeLog(backupRestore.defaultLogFilePath(fileNameOrPath, mode))
        currentUnit = ""
        _downloadedFilePath = ""
        _cloudLocalSyncDir = ""
        _cloudAccountId = 0
    }

    function _done() {
        _cleanUp()
        done()
    }

    function _error(errorMainText, errorDetailText) {
        _cleanUp()
        error(errorMainText, errorDetailText)
    }

    function _cleanUp() {
        if (root._cloudLocalSyncDir.length > 0) {
            // delete any files uploaded to or downloaded from the cloud
            _backupUtils.removeDirectory(root._cloudLocalSyncDir)
        }
    }

    function _fileDirForPath(filePath) {
        var sepIndex = filePath.lastIndexOf('/')
        return sepIndex >= 0 ? filePath.substr(0, sepIndex) : ""
    }

    function _removeLastDirSeparator(dirPath) {
        if (dirPath[dirPath.length-1] == '/') {
            return dirPath.substr(0, dirPath.length-1)
        }
        return dirPath
    }

    function _sendFileToCloud(filePath) {
        cloudSync.resetState()
        var dir = _fileDirForPath(filePath)
        if (cloudSync.uploadToCloud(_cloudAccountId, dir)) {
            _logText("Triggered backups upload to cloud account " + _cloudAccountId + " from dir " + dir)
        } else {
            _handleAccountSyncSetupError()
        }
    }

    function _findUnits(forCloud) {
        var units = []
        for (var i=0; i<unitListModel.count; i++) {
            var data = unitListModel.get(i)
            if (forCloud && data.name == "Gallery") {
                // Gallery is excluded from cloud backup because photos/videos take a lot of space
                // and we have other Gallery sync solutions for these already.
                // TODO have units register e.g. 'nocloud' so we can filter it here instead of hardcoding.
                continue
            }
            units.push(backupRestore.unitInfo(data.name, data.script))
        }
        return units
    }

    function _updateStatus(statusText) {
        _logText(statusText)
        statusUpdate(statusText)
    }

    function _logText(text) {
        if (!backupRestore.log("[UI] " + text)) {
            console.log(text)
        }
    }

    // Use this as errorDetailText when the error is not explained by the errorMainText
    // (e.g. if it's not something simple like no backups found for restoration)
    function _logInfoText() {
        //: Indicates where to find the detailed operation log. %1 = the path to the log file
        //% "Detailed log in %1"
        return qsTrId("vault-la-log_file_at").arg(backupRestore.logFilePath)
    }

    function _initProgress() {
        if (_mode == SimpleBackupRestore.Backup) {
            // Backup: Preparing/[units]/Compressing/Finalizing/Finished/[upload-if-cloud]
            _maxSteps = 5 + _units.length
            if (_cloudAccountId) {
                _maxSteps++
            }
        } else if (_mode == SimpleBackupRestore.Restore) {
            // Restore: [download-if-cloud]/Preparing/LoadingArchive/[units]/Finalizing/Finished
            _maxSteps = 6 + _units.length
            if (_cloudAccountId) {
                _maxSteps++
            }
        } else if (_mode == SimpleBackupRestore.Compress) {
            // Compress: Preparing/Compressing/Finalizing/Finished/[upload-if-cloud]
            _maxSteps = 4
            if (_cloudAccountId) {
                _maxSteps++
            }
        }
        _currentStep = 0
    }

    function _incrementProgress() {
        _currentStep += 1
        progress = _currentStep / _maxSteps
    }

    // if the initial account sync setup failed, it's due to the account configuration
    function _handleAccountSyncSetupError() {
        //: Failed to connect to the cloud account's storage service
        //% "Unable to connect to the cloud service."
        _error(qsTrId("vault-la-unable_to_connect_to_cloud"),
              //: More information displayed when failed to connect to the cloud account's storage service.
              //% "Please verify the account is set up for Storage services in Settings | Accounts."
              qsTrId("vault-la-unable_to_connect_to_cloud_please_verify_account"))
    }

    function _handleBackupRestoreError() {
        if (backupRestore.error == SimpleBackupRestore.NoDiskSpace) {
            if (backupRestore.mode == SimpleBackupRestore.Backup || backupRestore.mode == SimpleBackupRestore.Compress) {
                if (_cloudAccountId > 0) {
                    //% "Not enough disk space on your device to create a backup to upload to the cloud."
                    _error(qsTrId("vault-la-no_local_disk_space_for_backup"), _logInfoText())
                } else {
                    //% "Not enough disk space on the memory card."
                    _error(qsTrId("vault-la-no_memory_card_space_for_backup"), _logInfoText())
                }
            } else {
                //% "Not enough disk space on your device to load the backup file."
                _error(qsTrId("vault-la-no_local_disk_space_for_restore"), _logInfoText())
            }
        } else if (backupRestore.error == SimpleBackupRestore.ProcessError && backupRestore.currentUnit.length > 0) {
            if (backupRestore.mode == SimpleBackupRestore.Backup) {
                //: Shown when data backup fails for a specific data set. %1 = name of data set, e.g. "Gallery", "Messages", "Browser"
                //% "An error occurred while backing up %1 data."
                _error(qsTrId("vault-la-unit_backup_failed").arg(backupRestore.currentUnit), _logInfoText())
            } else {
                //: Shown when data restore fails for a specific data set. %1 = name of data set, e.g. "Gallery", "Messages", "Browser"
                //% "An error occurred while restoring %1 data."
                _error(qsTrId("vault-la-unit_restore_failed").arg(backupRestore.currentUnit), _logInfoText())
            }
        } else {
            if (backupRestore.mode == SimpleBackupRestore.Backup) {
                //: Shown when data backup operation fails.
                //% "Data backup failed. See the error log for more details."
                _error(qsTrId("vault-la-backup_failed_see_error_log"), _logInfoText())
            } else if (backupRestore.mode == SimpleBackupRestore.Restore) {
                //: Shown when data restore operation fails.
                //% "Data restoration failed. See the error log for more details."
                _error(qsTrId("vault-la-restore_failed_see_error_log"), _logInfoText())
            } else {
                //: Label which is displayed when the migration operation for a particular backup fails.
                //% "The backup could not be updated."
                _error(qsTrId("vault-la-backup_migration_error"), _logInfoText())
            }
        }
    }

    property CloudBackupSyncTrigger cloudSync: CloudBackupSyncTrigger {
        onCloudSyncProgress: {
            switch (status) {
            case AccountSyncManager.SyncStarted:
                root.syncing = true
                if (root._mode == SimpleBackupRestore.Backup || root._mode == SimpleBackupRestore.Compress) {
                    //% "Uploading backup to cloud service"
                    root._updateStatus(qsTrId("vault-la-uploading_to_cloud"))
                } else {
                    //% "Downloading backups from cloud service"
                    root._updateStatus(qsTrId("vault-la-downloading_from_cloud"))
                }
                break
            case AccountSyncManager.SyncFinished:
                root.syncing = false
                if (root._mode == SimpleBackupRestore.Backup || root._mode == SimpleBackupRestore.Compress) {
                    //% "Backup successfully uploaded"
                    root._updateStatus(qsTrId("vault-la-uploaded"))
                    root._done()
                } else {
                    root._logText("Data will be restored from backup file " + root._downloadedFilePath)
                    backupRestore.restore(root._units, root._downloadedFilePath)
                }
                break
            case AccountSyncManager.SyncError:
                root.syncing = false
                root._logText("Sync error: " + errorString)
                if (root._mode == SimpleBackupRestore.Backup || root._mode == SimpleBackupRestore.Compress) {
                    //% "Unable to send the backup file to the cloud service"
                    root._error(qsTrId("vault-la-backup_upload_error"), root._logInfoText())
                } else {
                    //% "Unable to download backup files from the cloud service"
                    root._error(qsTrId("vault-la-backup_download_error"), root._logInfoText())
                }
                break
            case AccountSyncManager.SyncAborted:
                root.syncing = false
                //% "The backup file transfer operation was canceled"
                root._error(qsTrId("vault-la-backup_transfer_canceled"), root._logInfoText())
                break
            }
        }
    }

    property BackupUtils _backupUtils: BackupUtils {}

    property SimpleBackupRestore backupRestore: SimpleBackupRestore {
        onStatusChanged: {
            switch (status) {
            case SimpleBackupRestore.Preparing:
                root._incrementProgress()
                if (root._mode == SimpleBackupRestore.Backup) {
                    root._logText("Preparing to backup files to " + backupRestore.compressedFilePath)
                } else if (root._mode == SimpleBackupRestore.Restore) {
                    root._logText("Preparing to restore files from " + backupRestore.compressedFilePath)
                } else if (root._mode == SimpleBackupRestore.Compress) {
                    root._logText("Preparing to compress files to " + backupRestore.compressedFilePath)
                }
                break
            case SimpleBackupRestore.UnitScriptStarted:
                root._incrementProgress()
                //: Currently reading data to backup or restore
                //% "Reading data"
                root._updateStatus(qsTrId("vault-la-reading_data"))
                break
            case SimpleBackupRestore.UnitScriptFinished:
                break
            case SimpleBackupRestore.Compressing:
                root._incrementProgress()
                //: Currently in the process of compressing the user data to a backup file
                //% "Compressing data to backup file"
                root._updateStatus(qsTrId("vault-la-compressing_data_to_backup"))
                break
            case SimpleBackupRestore.LoadingArchive:
                root._incrementProgress()
                //: Currently in the process of extracting the user data from a backup file
                //% "Extracting data from backup file"
                root._updateStatus(qsTrId("vault-la-extracting_data_from_backup"))
                break
            case SimpleBackupRestore.Finalizing:
                root._incrementProgress()
                //: Currently finalizing the data backup or restore process
                //% "Finalizing operation"
                root._updateStatus(qsTrId("vault-la-finalizing_operation"))
                break
            case SimpleBackupRestore.Finished:
                if (backupRestore.error == SimpleBackupRestore.NoError) {
                    root._incrementProgress()
                    if (backupRestore.mode == SimpleBackupRestore.Backup
                            || backupRestore.mode == SimpleBackupRestore.Compress) {
                        if (_cloudAccountId > 0) {
                            _sendFileToCloud(backupRestore.compressedFilePath)
                            return
                        }
                    }
                    //: Finished the data restore process
                    //% "Finished"
                    root._updateStatus(qsTrId("vault-la-finished"))
                    root._done()
                } else {
                    root._handleBackupRestoreError()
                }
                break
            }
        }

        onCurrentUnitChanged: {
            root.currentUnit = currentUnit
        }
    }

}
