import QtQuick 2.0
import Sailfish.Silica 1.0

TextField {
    property var regExp
    acceptableInput: regExp ? regExp.test(text) : true

    onActiveFocusChanged: if (!activeFocus) errorHighlight = !acceptableInput
    onAcceptableInputChanged: if (acceptableInput) errorHighlight = false

    //: Keep short, placeholder label that cannot wrap
    //% "E.g. www.example.com"
    placeholderText: qsTrId("settings_network-la-network_address_example")

    //% "Network address"
    label: qsTrId("settings_network-la-network_address")
    hideLabelOnEmptyField: false

    inputMethodHints: Qt.ImhNoPredictiveText | Qt.ImhNoAutoUppercase
}
