/*
    Copyright (C) 2016 Jolla Ltd.
    Contact: Raine Mäkeläinen <raine.makelainen@jolla.com>
*/

import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    id: root

    property alias modemManager: modemManager
    property alias activeSim: modemManager.activeSim
    property alias activeSimCount: modemManager.activeSimCount
    property alias activeModem: modemManager.activeModem
    property alias availableModemCount: modemManager.availableModemCount
    property alias presentModemCount: modemManager.presentModemCount
    property alias valid: modemManager.valid
    property alias simCount: modemManager.simCount
    property alias simNames: modemManager.simNames
    property alias availableModems: modemManager.availableModems
    property alias enabledModems: modemManager.enabledModems
    property alias presentSims: modemManager.presentSims
    // "auto", "voice", "data"
    property alias controlType: modemManager.controlType

    readonly property bool active: {
        if (!!presentSims && enabledModems.length > 1 && simCount > 1) {
            for (var i = 0; i < presentSims.length; i++) {
                if (presentSims[i] && i != activeSim) {
                    // alternative SIM found
                    return true
                }
            }
        }
        return false
    }

    function setActiveSimIndex(index) {
        if (activeSim !== index) {
            modemManager.setActiveSim(index)
        }
    }

    function switchActiveSim() {
        if (!active) {
            return
        }

        setActiveSimIndex(activeSim === 0 ? 1 : 0)
    }

    SimManager {
        id: modemManager
    }
}
