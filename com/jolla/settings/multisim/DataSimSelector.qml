/*
    Copyright (C) 2016 Jolla Ltd.
    Contact: Raine Mäkeläinen <raine.makelainen@jolla.com>
*/

import QtQuick 2.2
import Sailfish.Silica 1.0
import Sailfish.Telephony 1.0

SimSelectorBase {
    id: root

    function show() {
        if (enabled) {
            comboBox.menu.open(comboBox)
        }
    }

    signal closed

    width: parent.width
    height: comboBox.height
    controlType: SimManagerType.Data
    modemManager.objectName: "DataSimSelector"

    onActiveSimChanged: comboBox.currentIndex = activeSim

    // We must be enabled if there is any present SIM to select that is not the activeSim
    enabled: {
        if (!!presentSims) {
            for (var i = 0; i < presentSims.length; i++) {
                if (presentSims[i] && i != activeSim) {
                    // alternative SIM found
                    return true
                }
            }
        }
        return false
    }

    ComboBox {
        id: comboBox
        width: parent.width
        //% "Use SIM card"
        label: qsTrId("settings_networking-la-use_sim_card")
        currentIndex: root.activeSim

        //% "None"
        value: (currentItem !== null && currentItem.text !== "") ? currentItem.text : qsTrId("settings_networking-la-none")
        opacity: root.enabled ? 1.0 : 0.4
        Behavior on opacity {
            FadeAnimation {}
        }

        menu: ContextMenu {
            id: contextMenu

            onClosed: root.closed()
            Repeater {
                model: root.modemManager.modemSimModel
                delegate: MenuItem {
                    down: mouseBlocker.pressed
                    highlighted: down || root.activeSim === index
                    text: errorState.errorState ? (model.shortSimDescription + " | " + errorState.shortErrorString) : model.simName
                    enabled: errorState.errorState != "noSimInserted" && errorState.errorState != "modemDisabled"

                    // Do not let MenuItem to trigger clicked signal as the ContextMenu updates
                    // currentIndex automatically. Update ComboBox.currentIndex only when active
                    // SIM has changed.
                    // Active SIM card is not updated if PIN code is needed / not given.
                    MouseArea {
                        id: mouseBlocker
                        anchors.fill: parent
                        onClicked: {
                            root.modemManager.setActiveSim(index)
                            contextMenu.close()
                        }
                    }

                    SimErrorState {
                        id: errorState
                        multiSimManager: root.modemManager
                        modemPath: modem
                    }
                }
            }
        }
    }
}
