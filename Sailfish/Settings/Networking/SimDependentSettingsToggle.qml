import QtQuick 2.5
import Sailfish.Silica 1.0
import Sailfish.Telephony 1.0
import com.jolla.settings 1.0

SettingsToggle {
    property var simManager: SimManager {
        controlType: SimManagerType.Data
    }

    property bool simToggleAvailable: simManager.availableSimCount > 0
                                      && simManager.activeSim >= 0

    function handleSimSettingsToggled() {
        if (simToggleAvailable) {
            return false
        }

        if (simManager.availableSimCount === 0) {
            errorNotification.notify(SettingsControlError.NoSimAvailable)
        } else if (simManager.activeSim < 0) {
            errorNotification.notify(SettingsControlError.NoSimActive)
            goToSettings("system_settings/connectivity/mobile")
        }
        return true
    }
}
