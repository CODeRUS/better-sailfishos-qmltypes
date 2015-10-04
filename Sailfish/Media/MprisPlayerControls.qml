import QtQuick 2.0
import org.nemomobile.mpris 1.0

Loader {
    id: controlsLoader

    active: mprisManager.availableServices.length > 0

    Component.onCompleted: setSource("MprisManagerControls.qml", { "mprisManager": mprisManager, "parent": Qt.binding(function() { return controlsLoader.parent }) })

    MprisManager {
        id: mprisManager
    }
}
