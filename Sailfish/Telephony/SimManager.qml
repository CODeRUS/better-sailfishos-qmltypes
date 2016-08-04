import QtQuick 2.2
import Sailfish.Telephony 1.0
import MeeGo.QOfono 0.2
import org.nemomobile.ofono 1.0
import org.nemomobile.configuration 1.0
import org.nemomobile.dbus 2.0

Item {
    readonly property alias valid: modemManager.valid
    readonly property alias ready: modemManager.ready
    readonly property int activeSim: modemManager.availableModems.indexOf(activeModem)

    // Active modem is always registered
    readonly property string activeModem: dsssMode || !Telephony.multiSimSupported
                                 ? modemManager.enabledModems[0] || ''
                                 : (controlType & SimManagerType.Voice) ? modemManager.defaultVoiceModem
                                                                        : modemManager.defaultDataModem

    // IMSI of default voice/data sim
    readonly property alias defaultVoiceSim: modemManager.defaultVoiceSim
    readonly property alias defaultDataSim: modemManager.defaultDataSim

    readonly property int availableModemCount: modemManager.availableModems.length
    // Dual SIM Single Standby
    readonly property bool dsssMode: multiModemsSupported.value ? false
                                                                : (availableModemCount > 1 && modemManager.enabledModems.length === 1)
    property alias availableModems: modemManager.availableModems
    property alias enabledModems: modemManager.enabledModems
    property var simNames: [ "", "" ] // placeholders due to code binding to simNames[0] etc
    property alias availableSimCount: simListModel.count // no. of SIMs that are not currently locked or otherwise unavailable
    property bool revalidate

    // The control type of the SimManager
    // SimManagerType.Auto - default both voice and data SIM / modem
    // SimManagerType.Voice - controlling voice SIM / modem (takes care of SMSes as well)
    // SimManagerType.Data - controlling data SIM / modem
    property int controlType: SimManagerType.Auto

    property alias presentModemCount: modemManager.presentSimCount
    property alias activeSimCount: modemManager.activeSimCount
    property alias simCount: modemManager.presentSimCount
    property alias presentSims: modemManager.presentSims

    property alias modemSimModel: modemSimModel

    // Subscriber identity is normally available only after SIM PIN is entered.
    // OfonoSimInfo caches the subscriber identity after SIM PIN has been entered once.
    // OfonoModemManager.defaultVoiceSim contains last known voice sim imsi.
    // Thus, finding voice modem is possible without entering sim pin or
    // knowing modem.
    // If only one sim is inserted, try to use the modem that contains the sim
    // as a default modem.
    readonly property string voiceModem: {
        var i = 0
        for (i = 0; i < simData.count; ++i) {
            var sim = simData.itemAt(i)
            if (sim && sim.isVoiceSim) {
                return sim.modemPath
            }
        }

        // Only one sim card inserted.
        if (simCount === 1) {
            var modemContainingSim = ""
            for (i = 0; i < presentSims.length; ++i) {
                if (presentSims[i]) {
                    return availableModems[i]
                }
            }
        }

        return ""
    }

    // Set to true if we allow multiple modems to be enabled, i.e. phase 2
    ConfigurationValue {
        id: multiModemsSupported
        key: "/jolla/ofono/multimodem"
        defaultValue: false
    }

    function updateSimNames() {
        simNames = _updateSimData()
    }

    function modemHasPresentSim(modemPath) {
        return presentSims.length > 0 && presentSims[availableModems.indexOf(modemPath)] || false
    }

    function allSimsPresent() {
        var foundMissingSim = false
        for (var i = 0; i < presentSims.length; ++i) {
            if (!presentSims[i]) {
                foundMissingSim = true
                break
            }
        }
        return !foundMissingSim
    }

    function setActiveSim(simIndex) {
        if (multiModemsSupported.value) {
            if (simIndex >= 0 && simIndex < simData.count) {
                var sim = simData.itemAt(simIndex)
                if (sim && sim.available) {
                    if (controlType & SimManagerType.Voice) {
                        modemManager.defaultVoiceSim = sim.imsi
                    }
                    if (controlType & SimManagerType.Data) {
                        modemManager.defaultDataSim = sim.imsi
                    }
                } else if (sim) {
                    sim.makeDefaultVoiceSim = controlType & SimManagerType.Voice
                    sim.makeDefaultDataSim = controlType & SimManagerType.Data
                    pinQuery.call("requestSimPin", [ availableModems[simIndex] ])
                }
            } else {
                console.warn("Trying to activate sim index that is out of bounds.")
            }
        } else {
            modemManager.enabledModems = [ modemManager.availableModems[simIndex] ]
            modemManager.defaultDataSim = "auto"
            modemManager.defaultVoiceSim = "auto"
        }
    }

    function enableModem(modem, enabled) {
        if ((enabled && enabledModems.indexOf(modem) !== -1) ||
            (!enabled && enabledModems.indexOf(modem) === -1)) {
            return
        }

        var newEnabledModems = []
        for (var i = 0; i < availableModems.length; ++i) {
            var availableModemAtIndex = availableModems[i]
            if ((availableModemAtIndex !== modem && enabledModems.indexOf(availableModemAtIndex) !== -1) ||
                  enabled && availableModemAtIndex === modem) {
                newEnabledModems.push(availableModemAtIndex)
            }
        }

        enabledModems = newEnabledModems
    }

    function indexOfModem(modemPath) {
        return modemManager.availableModems.indexOf(modemPath)
    }

    function indexOfModemFromImsi(imsi) {
        for (var i = 0; i < simData.count; ++i) {
            var sim = simData.itemAt(i)
            if (sim && sim.imsi == imsi) {
                return i
            }
        }
        return -1
    }

    function validateModemState() {
        if (!modemManager.ready) {
            revalidate = true
            return
        }

        revalidate = false

        if (!multiModemsSupported.value) {
            for (var i = 0; i < simData.count; ++i) {
                if (!simData.itemAt(i).valid) {
                    revalidate = true
                    return
                }
            }

            if (modemManager.enabledModems.length !== 1 || activeSim == -1 || !modemManager.presentSims[activeSim]) {
                // We should only have one enabled modem, and it should have a sim inserted
                for (i = 0; i < modemManager.availableModems.length; ++i) {
                    if (modemManager.presentSims[i]) {
                        console.warn("Setting active modem to", modemManager.availableModems[i])
                        modemManager.enabledModems = [ modemManager.availableModems[i] ]
                        return
                    }
                }
            }
        }
    }

    function _updateSimData() {
        var names = []
        for (var i = 0; i < simData.count; ++i) {
            var sim = simData.itemAt(i)
            //% "SIM%1"
            var shortSimDescription = qsTrId("sailfish-telephony-la-short_sim_identity").arg(i+1)

            var simName = shortSimDescription
            if (sim && sim.operatorDescription) {
                simName += " | " + sim.operatorDescription
            }
            names.push(simName)

            //% "SIM card %1"
            var longSimDescription =  qsTrId("sailfish-telephony-la-long_sim_identity").arg(i+1)
            var modem = availableModems[i]
            if (simData.count === modemSimModel.count) {
                modemSimModel.setProperty(i, "modem", modem)
                modemSimModel.setProperty(i, "modemEnabled", enabledModems.indexOf(modem) !== -1)
                modemSimModel.setProperty(i, "shortSimDescription", shortSimDescription)
                modemSimModel.setProperty(i, "longSimDescription", longSimDescription)
                modemSimModel.setProperty(i, "simName", simName)
                modemSimModel.setProperty(i, "imsi", sim && sim.imsi || "")
                modemSimModel.setProperty(i, "operator", sim && sim.operator || "")
                modemSimModel.setProperty(i, "operatorDescription", sim && sim.operatorDescription || "")
            } else {
                modemSimModel.append({
                                         "modem": modem,
                                         "modemEnabled": enabledModems.indexOf(modem) !== -1,
                                         "shortSimDescription": shortSimDescription,
                                         "longSimDescription": longSimDescription,
                                         "simName": simName,
                                         "imsi": sim && sim.imsi || "",
                                         "operator": sim && sim.operator || "",
                                         "operatorDescription": sim && sim.operatorDescription || ""
                                     })
            }
        }

        if (modemManager.ready) {
            modemSimModel.updated()
        }

        return names
    }

    ListModel {
        id: modemSimModel

        signal updated
    }

    DBusInterface {
        id: pinQuery
        service: "com.jolla.PinQuery"
        path: "/com/jolla/PinQuery"
        iface: "com.jolla.PinQuery"
    }

    OfonoSimListModel {
        id: simListModel
        requireSubscriberIdentity: true
    }

    OfonoModemManager {
        id: modemManager

        // This should not really touch active data sim.
        readonly property bool verifyVoiceModem: (controlType == SimManagerType.Voice) && Telephony.multiSimSupported && (enabledModems.length === 1)
        onVerifyVoiceModemChanged: {
            if (verifyVoiceModem) {
                var index = availableModems.indexOf(enabledModems[0])
                if (presentSims[index]) {
                    console.warn("Setting active modem to", availableModems[index])
                    setActiveSim(index)
                }
            }
        }

        onReadyChanged: if (ready && revalidate) validateModemState()
        onEnabledModemsChanged: {
            if (modemSimModel.count != simData.count) {
                _updateSimData()
            } else {
                for (var i = 0; i < simData.count; ++i) {
                    var modem = availableModems[i]
                    modemSimModel.setProperty(i, "modemEnabled", enabledModems.indexOf(modem) !== -1)
                }
            }
        }
    }

    Repeater {
        id: simData
        model: modemManager.availableModems
        delegate: Item {
            property alias valid: simManager.valid
            readonly property string imsi: (simInfo.valid && simInfo.subscriberIdentity) ||
                                           (simManager.valid && simManager.subscriberIdentity) || ""

            // Do not use cache subscriber identity provided by SimInfo rather use the
            // non-cached that is updated after pin entered.
            readonly property bool available: valid && simManager.present &&
                                              simManager.valid && simManager.subscriberIdentity &&
                                              simManager.pinRequired == OfonoSimManager.NoPin

            property bool makeDefaultDataSim
            property bool makeDefaultVoiceSim

            readonly property bool isVoiceSim: imsi && modemManager.defaultVoiceSim === imsi
            readonly property alias modemPath: simManager.modemPath

            onAvailableChanged: {
                if (available) {
                    if (makeDefaultDataSim) {
                        modemManager.defaultDataSim = imsi
                        makeDefaultDataSim = false
                    }
                    if (makeDefaultVoiceSim) {
                        modemManager.defaultVoiceSim = imsi
                        makeDefaultVoiceSim = false
                    }
                }
                _updateSimData()
            }

            readonly property string operator: {
                if (simManager.ready && simManager.present && networkRegistration.serviceProvider) {
                    return networkRegistration.serviceProvider
                }

                if (previousRegistration.value && previousRegistration.key) {
                    return previousRegistration.value
                }
                return ""
            }
            readonly property string operatorDescription: {
                if (operator) {
                    return operator
                }

                //: We don't know which operator is associated with the SIM
                //% "Unknown"
                return qsTrId("sailfish-telephony-la-sim_operator_unknown")
            }

            onOperatorDescriptionChanged: updateSimNames()

            OfonoSimManager {
                id: simManager
                modemPath: modelData
                onValidChanged: if (valid && revalidate) validateModemState()
            }
            OfonoNetworkRegistration {
                id: networkRegistration

                readonly property string serviceProvider: (simInfo.valid && simInfo.serviceProviderName) || name || ""
                readonly property bool updateSimNameCache: serviceProvider && previousRegistration.key

                onUpdateSimNameCacheChanged: {
                    if (updateSimNameCache) {
                        previousRegistration.value = serviceProvider
                    }
                }

                modemPath: modelData
            }
            ConfigurationValue {
                id: previousRegistration
                key: simInfo.valid ? "/jolla/ofono/registration_" + simInfo.subscriberIdentity : ""
            }
            OfonoSimInfo {
                id: simInfo
                modemPath: modelData
            }
        }
        onItemAdded: {
            updateSimNames()
        }
        onItemRemoved: {
            updateSimNames()
        }
    }
}
