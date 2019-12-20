import QtQuick 2.2
import Nemo.Notifications 1.0
import Sailfish.Secrets.Ui 1.0

Notification {
    icon: "icon-lock-warning"
    isTransient: true

    function show(error) {
        icon = "icon-lock-warning"

        if (error == StorageError.StorageErrorKeyImportFailed) {
            //% "Importing key failed"
            previewSummary = qsTrId("secrets_ui-la-importing_key_failed")
        } else if (error == StorageError.StorageErrorKeyDeletionFailed) {
            //% "Deletion key failed"
            previewSummary = qsTrId("secrets_ui-la-deletion_key_failed")
        } else if (error == StorageError.StorageErrorKeyAlreadyExistsError) {
            icon = "icon-lock-information"
            //% "Key already exists"
            previewSummary = qsTrId("secrets_ui-la-key_already_exists")
        }

        if (previewSummary) {
            publish()
        }
        previewSummary = ""
    }
}
