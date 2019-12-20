import QtQuick 2.2
import Nemo.Notifications 1.0
import Sailfish.Secrets 1.0 as Secrets

Notification {
    icon: "icon-lock-warning"
    isTransient: true

    function show(error) {
        icon = "icon-lock-warning"
        if (error == Secrets.Result.IncorrectAuthenticationCodeError) {
            //% "Incorrect password, try again"
            previewSummary = qsTrId("secrets_ui-la-incorrect-password")
        }

        if (previewSummary) {
            publish()
        }
        previewSummary = ""
    }
}
