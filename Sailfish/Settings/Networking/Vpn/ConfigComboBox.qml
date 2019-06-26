import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Settings.Networking.Vpn 1.0

ComboBox {
    id: root

    property var values
    property alias delegate: repeater.delegate

    property var selection: values && values.length > currentIndex ? values[currentIndex] : undefined

    function setValue(value) {
        for (var i = 0; i < values.length; ++i) {
            if ((values[i] == value) ||
                (values[i] == '_default' && !value)) {
                currentIndex = i
                return
            }
        }
        currentIndex = -1
    }

    width: parent.width
    menu: ContextMenu {
        Repeater {
            id: repeater

            model: root.values
            delegate: MenuItem {
                text: VpnTypes.presentationName(modelData)
            }
        }
    }
}

