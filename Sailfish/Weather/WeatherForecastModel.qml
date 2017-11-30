import QtQuick 2.0
import QtQuick.XmlListModel 2.0
import Sailfish.Weather 1.0
import "WeatherModel.js" as WeatherModel

ListModel {
    id: root

    property var weather
    property bool ready
    property bool active: true
    property date timestamp
    readonly property int locationId: weather ? weather.locationId : -1
    property int status: Weather.Loading

    function reload() {
        forecast.reload()
    }
    function update() {
        if (active) {
            ready = true
            if (WeatherModel.updateAllowed(180*60*1000)) { // update allowed every 3 hours
                reload()
            }
        }
    }

    onActiveChanged: update()
    Component.onCompleted: update()

    property var forecast: XmlListModel {
        onStatusChanged: {
            if (status == XmlListModel.Ready) {
                var currentDate = new Date(timestamp.getTime())
                currentDate.setHours(0)
                currentDate.setMinutes(0)
                var weatherData = []
                for (var i = 0; i < count; i++) {
                    var weather = WeatherModel.getWeatherData(get(i), true)

                    if (weather.timestamp < currentDate) {
                        continue
                    }
                    weatherData[weatherData.length] = weather
                }
                while (root.count > weatherData.length) {
                    root.remove(weatherData.length)
                }
                for (var i = 0; i < weatherData.length; i++) {
                    if (i < root.count) {
                        root.set(i, weatherData[i])
                    } else {
                        root.append(weatherData[i])
                    }
                }
                root.status = Weather.Ready
            } else {
                if (status === XmlListModel.Error) {
                    root.status = Weather.Error
                    console.log("WeatherForecastModel - could not obtain forecast weather data")
                } else if (status == XmlListModel.Loading) {
                    root.status = Weather.Loading
                }
            }
        }

        query: "/xml/weather/fc"
        source: ready && root.locationId > 0 ? "http://feed-jll.foreca.com/jolla-jan14fi/data.php?l=" + root.locationId + "&products=daily" : ""

        XmlRole {
            name: "code"
            query: "@s/string()"
        }
        XmlRole {
            name: "timestamp"
            query: "@dt/string()"
        }
        XmlRole {
            name: "high"
            query: "@tx/string()"
        }
        XmlRole {
            name: "low"
            query: "@tn/string()"
        }
        XmlRole {
            name: "windSpeed"
            query: "@wsa/number()"
        }
        XmlRole {
            name: "windDirection"
            query: "@wn/string()"
        }
        XmlRole {
            name: "accumulatedPrecipitation"
            query: "@pr/string()"
        }
    }
}
