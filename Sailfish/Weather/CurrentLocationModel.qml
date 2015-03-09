import QtQuick 2.0
import QtPositioning 5.2
import QtQuick.XmlListModel 2.0
import org.nemomobile.keepalive 1.0
import MeeGo.Connman 0.2

Item {
    id: model

    property bool ready
    property bool error
    property string city
    property string locationId
    property bool metric: true
    property bool positioningAllowed
    property bool locationObtained
    property bool active: true
    property real searchRadius: 10 // find biggest city in specified kilometers
    property var coordinate: positionSource.position.coordinate

    property NetworkTechnology gpsTech
    property bool gpsPowered: gpsTech && gpsTech.powered
    property string longitude: format(coordinate.longitude)
    property string latitude: format(coordinate.latitude)
    property bool waitForSecondUpdate

    function format(value) {
        // optimize Foreca backend caching by
        // rounding to closest even decimal
        // (0.02 degree accuracy) e.g. 0.99 -> 1.00, 175.5637 -> 175.56
        if (value) {
            var angle = value
            var integer = Math.floor(value)
            var decimal = 2*Math.round(50*(angle - integer))
            if (decimal == 100) {
                integer = Math.floor(value+1)
                decimal = 0
            }
            return integer.toString() + "." + (decimal < 10 ? "0" : "") + decimal.toString()
        } else {
            return "0.0"
        }
    }
    function updateLocation() {
        active = true
        // first update returns cached location, wait for real position fix
        waitForSecondUpdate = true
    }
    function reloadModel() {
        locationModel.reload()
    }

    XmlListModel {
        id: locationModel

        query: "/searchdata/location"
        source: locationObtained ? "http://fnw-jll.foreca.com/findloc.php"
                                   + "?lon=" + longitude
                                   + "&lat=" + latitude
                                   + "&format=xml/jolla-sep13fi"
                                   + "&radius=" + searchRadius
                                 :  ""
        onStatusChanged: {
            if (status === XmlListModel.Ready && count > 0) {
                var location = get(0)
                locationId = location.locationId
                city = location.city
                metric = (location.locale !== "gb" && location.locale !== "us")
                ready = true
            }
            if (status !== XmlListModel.Loading) {
                if (backgroundJob.running) {
                    backgroundJob.finished()
                }
            }
            error = (status === XmlListModel.Error)
        }

        XmlRole {
            name: "locationId"
            query: "id/string()"
        }
        XmlRole {
            name: "city"
            query: "name/string()"
        }
        XmlRole {
            name: "locale"
            query: "land/string()"
        }
    }
    PositionSource {
        id: positionSource
        active: model.positioningAllowed && model.active
        onPositionChanged: {
            locationObtained = true
            if (gpsPowered && !waitForSecondUpdate) {
                model.active = false
            }
            waitForSecondUpdate = false
        }
    }
    BackgroundJob {
        id: backgroundJob

        enabled: true
        frequency: BackgroundJob.ThirtyMinutes
        onTriggered: model.updateLocation()
    }
    NetworkManagerFactory { id: networkManager }
    Connections {
        target: networkManager.instance
        onTechnologiesChanged: gpsTech = networkManager.instance.getTechnology("gps")
    }
}
