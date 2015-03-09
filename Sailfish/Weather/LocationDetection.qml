pragma Singleton
import QtQuick 2.2
import Sailfish.Weather 1.0
import com.jolla.settings.system 1.0

Item {
    id: root

    property bool ready: model && model.ready
    property bool error: model && model.error
    property string city: ready ? model.city : true
    property string locationId: ready ? model.locationId : ""
    property bool positioningAllowed: locationSettings.locationEnabled
    property bool metric: ready ? model.metric : true
    property QtObject model

    onPositioningAllowedChanged: handleLocationSetting()
    Component.onCompleted: handleLocationSetting()

    function updateLocation() {
        if (positioningAllowed && model) {
            model.updateLocation()
        }
    }
    function reloadModel() {
        if (positioningAllowed && model) {
            model.reloadModel()
        }
    }

    function handleLocationSetting() {
        if (positioningAllowed) {
            if (!model) {
                var modelComponent = Qt.createComponent("CurrentLocationModel.qml")
                if (modelComponent.status === Component.Ready) {
                    model = modelComponent.createObject(root)
                    model.positioningAllowed = Qt.binding(function() {
                        return positioningAllowed
                    })
                } else {
                    console.log(modelComponent.errorString())
                }
            }
        }
    }
    LocationSettings { id: locationSettings }
}
