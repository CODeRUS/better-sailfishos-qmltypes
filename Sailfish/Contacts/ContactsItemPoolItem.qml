import QtQuick 2.0
import Sailfish.Silica 1.0

RecyclingDelegate {
    property real leftMargin: -1

    function remove(contactIdCheck) {
        if (model.contactId === contactIdCheck) {
            item.remove()
        }
    }
    Component.onCompleted: {
        if (leftMargin !== -1) {
            // not a binding - change it if it needs to be for some reason
            item.leftMargin = leftMargin
        }
    }
}
