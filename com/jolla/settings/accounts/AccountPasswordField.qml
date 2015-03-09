import QtQuick 2.0
import Sailfish.Silica 1.0

TextField {
    width: parent.width
    inputMethodHints: Qt.ImhNoPredictiveText | Qt.ImhNoAutoUppercase
    echoMode: TextInput.Password
    placeholderText: label

    //% "Password"
    label: qsTrId("components_accounts-la-password")

    EnterKey.enabled: text || inputMethodComposing
    EnterKey.iconSource: "image://theme/icon-m-enter-next"
}
