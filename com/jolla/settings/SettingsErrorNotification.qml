import QtQuick 2.0
import Nemo.Notifications 1.0
import com.jolla.settings 1.0

Notification {
    isTransient: true
    icon: "icon-system-warning"

    function notify(error) {
        if (typeof error == "string") {
            previewBody = error
            publish()
            return
        }

        switch (error) {
        case SettingsControlError.InProgress:
            //% "In progress"
            previewBody = qsTrId("settings-la-in_progress")
            break
        case SettingsControlError.BlockedByAccessPolicy:
            //% "Disabled by Sailfish Device Manager"
            previewBody = qsTrId("settings-la-disabled_by_sailfish_device_manager")
            break
        case SettingsControlError.BlockedByFlightMode:
            //% "Disabled by flight mode"
            previewBody = qsTrId("settings-la-disabled_because_flight_mode_enabled")
            break
        case SettingsControlError.NotConnected:
            //% "No network connectivity"
            previewBody = qsTrId("settings-la-no-network-connectivity")
            break
        case SettingsControlError.ConnectionFailed:
            //% "Connection failure"
            previewBody = qsTrId("settings-la-connection_failure")
            break
        case SettingsControlError.ConnectionSetupRequired:
            //% "Connection setup required"
            previewBody = qsTrId("settings-la-connection_setup_required")
            break
        case SettingsControlError.NoSimAvailable:
            //% "No SIM card inserted"
            previewBody = qsTrId("settings-la-no_sim_card_inserted")
            break
        case SettingsControlError.NoSimActive:
            //% "SIM card disabled"
            previewBody = qsTrId("settings-la-sim_card_disabled")
            break
        default:
            // No notification
            console.warn("Trying to send an unknown error notification. Source of programming error.")
            return
        }

        publish()
    }
}
