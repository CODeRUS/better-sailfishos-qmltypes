import QtQuick 2.0
import Sailfish.Weather 1.0
import "WeatherModel.js" as WeatherModel

ListModel {
    id: root

    property bool hourly
    property var weather
    property alias active: model.active
    property date timestamp
    property alias status: model.status
    property int visibleCount: 6
    readonly property bool loading: forecastModel.status == Weather.Loading
    readonly property int locationId: weather ? weather.locationId : -1

    onLocationIdChanged: clear()

    function attemptReload() {
        model.attemptReload()
    }

    function reload() {
        model.reload()
    }

    readonly property WeatherRequest model: WeatherRequest {
        id: model

        source: root.locationId > 0 ?
                    "https://pfa.foreca.com/api/v1/forecast/"
                    + (hourly ? "hourly/" : "daily/") + root.locationId : ""


        // update allowed every half hour for hourly weather, every 3 hours for daily weather
        property int maxUpdateInterval: hourly ? 30*60*1000 : 180*60*1000
        function updateAllowed() {
            return status === Weather.Error || status === Weather.Null || WeatherModel.updateAllowed(maxUpdateInterval)
        }

        onRequestFinished: {
            var forecast = result["forecast"]
            if (result.length === 0 || forecast.length === "") {
                error = true
            } else {
                var weatherData = []
                for (var i = 0; i < forecast.length; i++) {
                    var data = forecast[i]
                    var weather = WeatherModel.getWeatherData(data)
                    if (hourly) {
                        if (i % 3 !== 0) continue
                        weather.timestamp =  new Date(data.time)
                        weather.temperature = data.temperature
                    } else {
                        var dateArray = data.date.split("-")
                        weather.timestamp = new Date(parseInt(dateArray[0]),
                                                     parseInt(dateArray[1] - 1),
                                                     parseInt(dateArray[2]))
                        weather.accumulatedPrecipitation = data.precipAccum
                        weather.maximumWindSpeed = data.maxWindSpeed
                        weather.windDirection = data.windDir
                        weather.high = data.maxTemp
                        weather.low = data.minTemp
                    }
                    weatherData[weatherData.length] = weather
                }

                if (hourly) {
                    var minimumTemperature = weatherData[0].temperature
                    var maximumTemperature = weatherData[0].temperature
                    for (i = 1; i < visibleCount + 1; i++) {
                        var temperature = weatherData[i].temperature
                        minimumTemperature = Math.min(minimumTemperature, temperature)
                        maximumTemperature = Math.max(maximumTemperature, temperature)
                    }
                    var range = maximumTemperature - minimumTemperature

                    var array = []
                    for (i = 0; i < visibleCount + 1; i++) {
                        weatherData[i].relativeTemperature = range > 0 ? (weatherData[i].temperature - minimumTemperature) / range : 0.5
                    }
                }

                while (root.count > weatherData.length) {
                    root.remove(weatherData.length)
                }

                for (i = 0; i < weatherData.length; i++) {
                    if (i < root.count) {
                        root.set(i, weatherData[i])
                    } else {
                        root.append(weatherData[i])
                    }
                }
            }
        }

        onStatusChanged: {
            if (status === Weather.Error) {
                console.log("WeatherForecastModel - could not obtain forecast weather data", weather ? weather.city : "", weather ? weather.locationId : "")
            }
        }
    }
}
