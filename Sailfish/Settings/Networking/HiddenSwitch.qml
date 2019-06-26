import QtQuick 2.0
import Sailfish.Silica 1.0

TextSwitch {
    property QtObject network

    //% "Hidden network"
    text: qsTrId("settings_network-la-hidden_network")
    checked: network.hidden
    automaticCheck: false
    onClicked: network.hidden = !network.hidden
}
