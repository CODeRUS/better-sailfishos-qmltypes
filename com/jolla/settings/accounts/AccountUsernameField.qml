import QtQuick 2.0
import Sailfish.Silica 1.0

TextField {
    width: parent.width
    inputMethodHints: Qt.ImhNoPredictiveText | Qt.ImhNoAutoUppercase
    placeholderText: label

    //% "Username"
    property string defaultLabel: qsTrId("components_accounts-la-username")
    label: defaultLabel

    EnterKey.enabled: text.length || inputMethodComposing
    EnterKey.iconSource: "image://theme/icon-m-enter-next"
}
