import QtQml 2.2
import Sailfish.Telephony 1.0
import MeeGo.QOfono 0.2

QtObject {
    id: root

    property var multiSimManager
    property string modemPath

    property OfonoSimManager simManager: OfonoSimManager { modemPath: root.modemPath }

    readonly property bool valid: simManager.valid

    readonly property bool simPresent: simManager.present || (!!multiSimManager &&
                                                              (multiSimManager.modemHasPresentSim(modemPath) ||
                                                               multiSimManager.allSimsPresent()))
    readonly property bool simActivationRequired: simPresent
                                              && (simManager.pinRequired == OfonoSimManager.SimPin
                                                  || simManager.pinRequired == OfonoSimManager.SimPuk)

    readonly property bool modemDisabled: {
        if (multiSimManager) {
            if (modemPath) {
                return multiSimManager.enabledModems.indexOf(modemPath) < 0
            } else {
                var availableModems = multiSimManager.availableModems
                var enabledModems = multiSimManager.enabledModems
                var foundEnabled = false
                for (var i = 0; i < availableModems.length; ++i) {
                    if (enabledModems.indexOf(availableModems[i]) >= 0) {
                        foundEnabled = true
                        break
                    }
                }

                // No enabled modems
                if (!foundEnabled) {
                    return true
                }
            }
        }

        // On single sim device, modems cannot be disabled.
        return false
    }
    property int modemIndex: multiSimManager && multiSimManager.ready ? multiSimManager.indexOfModem(root.modemPath) : -1
    property string shortSimName: modemIndex >= 0 ? multiSimManager.modemSimModel.get(modemIndex).shortSimDescription : ""

    readonly property string errorState: {
        // Note the order of precedence of errors: No SIM > Modem disabled > SIM inactive
        if (!simPresent) {
            return "noSimInserted"
        } else if (modemDisabled) {
            return "modemDisabled"
        } else if (simActivationRequired) {
            return "simActivationRequired"
        }
        return ""
    }

    readonly property string shortErrorString: {
        if (errorState == "noSimInserted") {
            //: Short format indicating that a SIM has not been inserted into the SIM slot (aim for less than 18 characters)
            //% "No SIM card"
            return qsTrId("sailfish-telephony-la-no_sim")
        } else if (errorState == "modemDisabled") {
            //: Short format indicating that a SIM is disabled (aim for less than 18 characters)
            //% "Disabled"
            return qsTrId("sailfish-telephony-la-disabled")
        } else if (errorState == "simActivationRequired") {
              //: Short format indicating that a SIM is locked (pin/puk not entered) (aim for less than 18 characters)
              //% "Locked"
            return qsTrId("sailfish-telephony-la-locked")
        }
        return ""
    }

    readonly property string errorString: {
        if (!Telephony.multiSimSupported) {
            if (errorState == "noSimInserted") {
                //: Indicates a SIM has not been inserted into the SIM slot
                //% "No SIM card inserted"
                return qsTrId("sailfish-telephony-la-no_sim_inserted")
            } else if (errorState == "modemDisabled") {
                //: Indicates a SIM is disabled
                //% "SIM is disabled"
                return qsTrId("sailfish-telephony-la-sim_disabled")
            } else if (errorState == "simActivationRequired") {
                  //: Indicates a SIM is locked (pin/puk not entered)
                  //% "SIM is locked"
                return qsTrId("sailfish-telephony-la-sim_locked")
            }
        }
        if (errorState == "noSimInserted") {
            //: Indicates a SIM has not been inserted into the SIM slot. %1 = the slot of the missing SIM, e.g. 'SIM1'
            //% "No SIM card in %1 slot"
            return qsTrId("sailfish-telephony-la-no_sim_in_slot_with_name").arg(shortSimName)
        } else if (errorState == "modemDisabled") {
            //: Indicates a SIM is disabled. %1 = the SIM name, e.g. 'SIM1'
            //% "%1 is disabled"
            return qsTrId("sailfish-telephony-la-sim_disabled_with_name").arg(shortSimName)
        } else if (errorState == "simActivationRequired") {
            //: Indicates a SIM is locked. %1 = the SIM name, e.g. 'SIM1' (pin/puk not entered)
            //% "%1 is locked"
            return qsTrId("sailfish-telephony-la-sim_locked_with_name").arg(shortSimName)
        }
        return ""
    }
}
