import QtQuick 2.0
import QtQuick.XmlListModel 2.0
import Sailfish.Weather 1.0
import "WeatherModel.js" as WeatherModel
import Nemo.Connectivity 1.0

XmlListModel {
    id: root

    property var weather
    property var savedWeathers
    property bool active: true
    property bool connectedToNetwork
    readonly property int locationId: weather ? weather.locationId : -1
    property date timestamp: new Date()

    signal error

    function updateAllowed() {
        return status == XmlListModel.Error || WeatherModel.updateAllowed()
    }

    function attemptReload() {
        if (updateAllowed()) {
            if (connectedToNetwork) {
                reload()
            }
        }
    }

    onError: {
        if (savedWeathersModel && weather) {
            savedWeathersModel.setErrorStatus(locationId)
            console.log("WeatherModel - could not obtain weather data", weather.city, weather.locationId)
        }
    }

    query: "/xml/weather/obs"
    source: locationId > 0 ? "http://feed-jll.foreca.com/jolla-jan14fi/data.php?l=" + root.locationId + "&products=cc" : ""


    onActiveChanged: if (active) attemptReload()

    onStatusChanged: {
        if (status == XmlListModel.Ready) {
            // Foreca can return an empty item for old weather stations
            if (count === 0 || get(0).temperature === "") {
                error()
            } else {
                var data = WeatherModel.getWeatherData(get(0), false)
                var json = {
                    "temperature": data.temperature,
                    "temperatureFeel": data.temperatureFeel,
                    "weatherType": data.weatherType,
                    "description": data.description,
                    "timestamp": data.timestamp
                }
                root.timestamp = data.timestamp
                savedWeathersModel.update(locationId, json)
            }
        } else if (status == XmlListModel.Error) {
            error()
        }
    }

    XmlRole {
        name: "code"
        query: "@s/string()"
    }
    XmlRole {
        name: "timestamp"
        query: "@dt/string()"
    }
    XmlRole {
        name: "temperature"
        query: "@t/string()"
    }
    XmlRole {
        name: "temperatureFeel"
        query: "@t/string()"
    }
    XmlRole {
        name: "windSpeed"
        query: "@ws/number()"
    }
    XmlRole {
        name: "windDirection"
        query: "@wn/string()"
    }
    XmlRole {
        name: "accumulatedPrecipitation"
        query: "@pr/string()"
    }

    property ConnectionHelper connectionHelper: ConnectionHelper {
        onNetworkConnectivityEstablished: {
            root.connectedToNetwork = true
            if (updateAllowed()) {
                root.reload()
            }
        }
        onNetworkConnectivityUnavailable: root.connectedToNetwork = false
    }
}
