import QtQml 2.0
import Sailfish.Settings.Networking 1.0
import Nemo.Connectivity 1.0 as Connectivity
import com.jolla.settings 1.0

Connectivity.MobileDataConnection {

    property SettingsErrorNotification _errors: SettingsErrorNotification {
        icon: "icon-system-connection-mobile"
    }

    onReportError: {
        if (errorString === "Operation failed") {
            _errors.notify(SettingsControlError.ConnectionFailed)
        } else if (errorString === "In progress") {
            _errors.notify(SettingsControlError.InProgress)
        } else if (errorString == "Provider not found") {
            //% "Cannot find service provider"
            _errors.notify(qsTrId("settings_network-la-cannot_find_service_provider"))
        } else if (errorString == "APN not found") {
            //% "Cannot find access point"
            _errors.notify(qsTrId("settings_network-la-cannot_find_access_point"))
        } else {
            _errors.notify(errorString)
        }
    }
}
