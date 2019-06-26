import QtQuick 2.0
import Sailfish.Silica 1.0

TextField {
    property Item nextFocusItem

    width: parent.width
    inputMethodHints: Qt.ImhNoPredictiveText | Qt.ImhNoAutoUppercase
    placeholderText: label

    EnterKey.iconSource: "image://theme/icon-m-enter-" + (nextFocusItem ? "next" : "close")
    EnterKey.onClicked: {
        if (nextFocusItem) {
            nextFocusItem.focus = true
        } else {
            focus = false
        }
    }
}
