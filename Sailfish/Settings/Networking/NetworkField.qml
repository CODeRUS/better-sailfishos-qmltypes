import QtQuick 2.0
import Sailfish.Silica 1.0

TextField {
    property var regExp
    property bool validInput: regExp ? regExp.test(text) : true

    onActiveFocusChanged: if (!activeFocus && !validInput) errorHighlight = true
    onValidInputChanged: if (validInput) errorHighlight = false

    //: Keep short, placeholder label that cannot wrap
    //% "E.g. www.example.com"
    placeholderText: qsTrId("settings_network-la-network_address_example")

    //% "Network address"
    label: qsTrId("settings_network-la-network_address")
    hideLabelOnEmptyField: false

    width: parent.width
    inputMethodHints: Qt.ImhNoPredictiveText | Qt.ImhNoAutoUppercase
}
