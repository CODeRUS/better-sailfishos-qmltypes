import QtQuick 2.0
import Sailfish.Silica 1.0
import org.nemomobile.contacts 1.0

Item {
    id: root

    property var globalPresenceState

    signal pressAndHold

    width: parent.width
    height: switchRow.height

    Row {
        id: switchRow

        PresenceSwitch {
            id: offlineSwitch
            switchPresenceState: Person.PresenceOffline
            globalPresenceState: root.globalPresenceState
            width: root.width / 3
            onClicked: {
                awaySwitch.cancelBusy()
                availableSwitch.cancelBusy()
            }
            onPressAndHold: root.pressAndHold()
        }
        PresenceSwitch {
            id: awaySwitch
            switchPresenceState: Person.PresenceAway
            globalPresenceState: root.globalPresenceState
            width: root.width / 3
            onClicked: {
                offlineSwitch.cancelBusy()
                availableSwitch.cancelBusy()
            }
            onPressAndHold: root.pressAndHold()
        }
        PresenceSwitch {
            id: availableSwitch
            switchPresenceState: Person.PresenceAvailable
            globalPresenceState: root.globalPresenceState
            width: root.width / 3
            onClicked: {
                offlineSwitch.cancelBusy()
                awaySwitch.cancelBusy()
            }
            onPressAndHold: root.pressAndHold()
        }
    }
}
