import QtQuick 2.0
import Sailfish.Silica 1.0
import MeeGo.QOfono 0.2

/*
  This provides a pulley menu for activating flight mode, and also for
  activating SIMs for single-modem devices.
  */
ViewPlaceholder {
    id: root

    property SimActivationPullDownMenu simActivationPullDownMenu

    enabled: text.length > 0 || hintText.length > 0

    text: {
        if (simActivationPullDownMenu.showFlightModeAction) {
            //% "Not available in flight mode"
            return qsTrId("settings_system-he-not_available_in_flight_mode")
        }
        if (simActivationPullDownMenu.modemManager
                && simActivationPullDownMenu.modemManager.availableModems.length <= 1) {
            if (simActivationPullDownMenu.showSimActivation) {
                //: Indicates a SIM is locked (pin/puk not entered)
                //% "SIM is locked"
                return qsTrId("settings_system-he-sim_locked")
            } else if (simActivationPullDownMenu.modemPath.length > 0 && !simActivationPullDownMenu.simManager.present) {
                //% "No SIM card inserted"
                return qsTrId("settings_system-he-no_sim")
            }
        }
        return ""
    }

    hintText: {
        if (simActivationPullDownMenu.showFlightModeAction) {
            //% "Pull down to turn off flight mode"
            return qsTrId("settings_system-he-settings_pull_down_turn_off_flight_mode")
        }
        return simActivationPullDownMenu.showSimActivation
                //% "Pull down to unlock SIM"
              ? qsTrId("settings_pin-he-unlock_sim_hint")
              : ""
    }
}
