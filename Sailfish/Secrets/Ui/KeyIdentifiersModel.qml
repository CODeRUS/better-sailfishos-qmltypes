import QtQuick 2.0
import Sailfish.Silica 1.0

// Fake model
ListModel {
    property bool ready
    property int _count // Remove
    Component.onCompleted: {
        for (var i = 0; i < _count; i++) {
            append({name: "Key " + String.fromCharCode(65 + index), collectionName: "Collection " + + String.fromCharCode(78 + index)})
        }
    }
}
