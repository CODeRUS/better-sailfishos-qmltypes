/****************************************************************************************
**
** Copyright (c) 2020 Open Mobile Platform LLC.
**
** License: Proprietary
**
****************************************************************************************/
pragma Singleton

import QtQuick 2.6
import Sailfish.Vault 1.0

BackupUtilsBase {
    function cloudBackupDescription(backupUnits) {
        //: Describes the data that will be backed up to cloud storage
        //% "The following data will be backed up: %1. Note that Gallery images and videos are not included."
        return qsTrId("vault-la-cloud_backup_description").arg(backupUnits)
    }

    function localBackupDescription(backupUnits) {
        //: Describes the data that will be backed up to local storage
        //% "The following data will be backed up: %1"
        return qsTrId("vault-la-local_backup_description").arg(backupUnits)
    }

    //% "Add cloud account"
    property string addCloudAccountText: qsTrId("vault-la-add_cloud_account")

    //% "Cannot connect to cloud service"
    property string cloudConnectErrorText: qsTrId("vault-la-cannot_connect_to_cloud_service")
}
