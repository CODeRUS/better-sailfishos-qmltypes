import QtQuick 2.0
import Sailfish.Silica 1.0

TextField {
    property Item nextFocusItem

    inputMethodHints: Qt.ImhNoPredictiveText | Qt.ImhNoAutoUppercase

    EnterKey.iconSource: "image://theme/icon-m-enter-" + (nextFocusItem ? "next" : "close")
    EnterKey.onClicked: {
        if (nextFocusItem) {
            nextFocusItem.focus = true
        } else {
            focus = false
        }
    }
}
