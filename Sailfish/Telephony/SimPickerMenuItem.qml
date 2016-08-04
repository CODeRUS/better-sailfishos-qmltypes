import QtQuick 2.1
import Sailfish.Silica 1.0

// Replaces the content of a ContextMenu with the SimPicker
// Usage:
//
// ContextMenu {
//   id: contextMenu
//   SimPickerMenuItem {
//     id: simSelector
//     menu: contextMenu
//     Behavior on opacity { FadeAnimation {} }
//     onSimSelected: dial(remoteUid, sim)
//   }
//   MenuItem {
//     text: "Call"
//     onClicked: simSelector.active = true
//   }
// }
//

SimPicker {
    id: simSelector
    property bool active
    property Item menu
    property alias fadeAnimationEnabled: fadeAnimationBehavior.enabled

    property int selectedSim: -1
    property string selectedModemPath

    signal triggerAction(int sim, string modemPath)

    width: parent.width
    // We want to transition smoothly from the context menu to the sim selector.
    // Placing the SimPicker directly in the ContextMenu Column causes nasty animation
    // glitches, so overide the context menu height and overlay the sim selector.
    enabled: active
    opacity: active ? 1.0 : 0.0
    Behavior on opacity {
        id: fadeAnimationBehavior
        FadeAnimator {}
    }

    parent: menu._contentColumn.parent

    onActiveChanged: {
        if (active && menu) {
            menu._setHighlightedItem(null)
        }
    }

    onSimSelected: {
        selectedSim = sim
        selectedModemPath = modemPath
        menu.hide()
    }

    states: State {
        when: simSelector.active
        name: "opened"
        PropertyChanges {
            target: menu
            _displayHeight: menu.active ? simSelector.height : 0
            closeOnActivation: false
        }
        PropertyChanges {
            target: menu._contentColumn
            visible: false
        }
    }

    Connections {
        target: menu

        onClosed: {
            simSelector.active = false
            if (selectedSim >= 0 && selectedModemPath) {
                triggerAction(selectedSim, selectedModemPath)
            }

            selectedSim = -1
            selectedModemPath = ""
        }
    }
}
