import QtQuick 2.0
import Sailfish.Weather 1.0
import "WeatherModel.js" as WeatherModel

WeatherRequest {
    property var weather
    property var savedWeathers
    property date timestamp: new Date()
    readonly property int locationId: !!weather ? weather.locationId : -1

    source: locationId > 0 ? "https://pfa.foreca.com/api/v1/current/" + locationId : ""

    function updateAllowed() {
        return status === Weather.Null || status === Weather.Error || WeatherModel.updateAllowed()
    }

    onRequestFinished: {
        var current = result["current"]
        if (result.length === 0 || current.temperature === "") {
            status = Weather.Error
        } else {
            var weather = WeatherModel.getWeatherData(current)
            weather.timestamp =  new Date(current.time)
            this.timestamp = weather.timestamp

            weather.temperature = current.temperature
            weather.feelsLikeTemperature = current.feelsLikeTemp
            var json = {
                "temperature": weather.temperature,
                "feelsLikeTemperature": weather.feelsLikeTemperature,
                "weatherType": weather.weatherType,
                "description": weather.description,
                "timestamp": weather.timestamp
            }
            savedWeathersModel.update(locationId, json)
        }
    }

    onStatusChanged: {
        if (status === Weather.Error) {
            if (savedWeathers) {
                savedWeathers.setErrorStatus(locationId)
            }

            console.log("WeatherModel - could not obtain weather data", weather ? weather.city : "", weather ? weather.locationId : "")
        }
    }
}
