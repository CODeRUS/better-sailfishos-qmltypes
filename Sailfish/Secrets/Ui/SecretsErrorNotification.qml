import QtQuick 2.2
import Nemo.Notifications 1.0
import Sailfish.Secrets 1.0 as Secrets

Notification {
    appIcon: "icon-lock-warning"
    isTransient: true

    function show(error) {
        if (error == Secrets.Result.IncorrectAuthenticationCodeError) {
            //% "Incorrect password, try again"
            summary = qsTrId("secrets_ui-la-incorrect-password")
        }

        if (summary) {
            publish()
        }
        summary = ""
    }
}
