// -*- qml -*-

import QtQuick 2.0

QtObject {
    id: container

    // This is a non visual QML object intended just to make it easier
    // the creation of other non visual objects by adding inline
    // children since the basic QtObject doesn't allow that.

    property list<QtObject> _data
    default property alias data: container._data
}
