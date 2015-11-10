var lastUpdate = new Date()

function updateAllowed() {
    // only update automatically if more than 30 minutes has
    // passed since the last update (30*60*1000)
    var now = new Date()
    var updateAllowed = (now - 1800000 > lastUpdate)
    if (updateAllowed) {
        lastUpdate = now
    }
    return updateAllowed
}

function getWeatherData(weather, forecast) {
    var dateArray
    if (forecast) {
        dateArray = weather.timestamp.split("-")
    } else {
        dateArray = weather.timestamp.split(" ")[0].split("-")
    }
    var timestamp =  new Date(parseInt(dateArray[0]),
                              parseInt(dateArray[1] - 1),
                              parseInt(dateArray[2]))

    if (!forecast && weather.timestamp.length > 0) {
        var timeArray = weather.timestamp.split(" ")[1].split(":")
        timestamp.setHours(timeArray[0])
        timestamp.setMinutes(timeArray[1])
        timestamp.setSeconds(timeArray[2])
    }

    var precipirationRateCode = weather.code.charAt(2)
    var precipirationRate = ""
    switch (precipirationRateCode) {
    case '0':
        //% "No precipitation"
        precipirationRate = qsTrId("weather-la-precipitation_none")
        break
    case '1':
        //% "Slight precipitation"
        precipirationRate = qsTrId("weather-la-precipitation_slight")
        break
    case '2':
        //% "Showers"
        precipirationRate = qsTrId("weather-la-precipitation_showers")
        break
    case '3':
        //% "Precipitation"
        precipirationRate = qsTrId("weather-la-precipitation_normal")
        break
    case '4':
        //% "Thunder"
        precipirationRate = qsTrId("weather-la-precipitation_thunder")
        break
    default:
        console.log("WeatherModel warning: invalid precipiration rate code", precipirationRateCode)
        break
    }

    var precipirationType = ""
    if (precipirationRateCode === '0') { // no rain
        //% "None"
        precipirationType = qsTrId("weather-la-precipirationtype_none")
    } else {
        var precipirationTypeCode = weather.code.charAt(3)
        switch (precipirationTypeCode) {
        case '0':
            //% "Rain"
            precipirationType = qsTrId("weather-la-precipitationtype_rain")
            break
        case '1':
            //% "Sleet"
            precipirationType = qsTrId("weather-la-precipitationtype_sleet")
            break
        case '2':
            //% "Snow"
            precipirationType = qsTrId("weather-la-precipitationtype_snow")
            break
        default:
            console.log("WeatherModel warning: invalid precipiration type code", precipirationTypeCode)
            break
        }
    }
    var windDirection = 0
    switch (weather.windDirection) {
    case 'N':
        windDirection = 0
        break
    case 'NE':
        windDirection = 45
        break
    case 'E':
        windDirection = 90
        break
    case 'SE':
        windDirection = 135
        break
    case 'S':
        windDirection = 180
        break
    case 'SW':
        windDirection = 225
        break
    case 'W':
        windDirection = 270
        break
    case 'NW':
        windDirection = 315
        break
    }

    var data = {
        "description": description(weather.code),
        "weatherType": weatherType(weather.code),
        "timestamp": timestamp,
        "cloudiness": (100*parseInt(weather.code.charAt(1))/4),
        "precipitationRate": precipirationRate,
        "precipitationType": precipirationType,
        "windSpeed": Math.round(weather.windSpeed),
        "windDirection": windDirection
    }

    if (forecast) {
        data.accumulatedPrecipitation = weather.accumulatedPrecipitation
        data.high = weather.high
        data.low = weather.low
    } else {
        data.temperature = weather.temperature
        data.temperatureFeel = weather.temperatureFeel
    }
    return data
}

function weatherType(code) {
    var dayTime = code.charAt(0) === "d" ? "day" : "night"
    var cloudiness = code.charAt(1)
    var precipirationRate = code.charAt(2)
    var precipirationType = code.charAt(3)

    var type
    switch(precipirationRate) {
    case '0':
        switch (cloudiness) {
        case '0':
        case '1':
        case '2':
            type = "cloud-" + dayTime + "-" + cloudiness
            break
        case '3':
            type = "cloud-3"
            break
        case '4':
            type = "cloud-4"
            break
        default:
            console.log("WeatherModel warning: invalid cloudiness code", cloudiness)
            break
        }
        break
    case '1':
    case '2':
    case '3':
    case '4':
        switch (precipirationType) {
        case '0':
            type = "rain-water-" + precipirationRate
            break
        case '1':
            type = "rain-sleet-" + precipirationRate
            break
        case '2':
            type = "rain-snow-" + precipirationRate
            break
        default:
            console.log("WeatherModel warning: invalid precipiration type code", precipirationType)
            break
        }
        break
    default:
        type = "cloud-day-0"
        console.log("WeatherModel warning: invalid precipiration rate code", precipirationRate)
        break
    }
    return type
}


function description(code) {
    var localizations = {
        //% "Clear"
        "000": qsTrId("weather-la-description_clear"),
        //% "Mostly clear"
        "100": qsTrId("weather-la-description_mostly_clear"),
        //% "Partly cloudy"
        "200": qsTrId("weather-la-description_partly_cloudy"),
        //% "Cloudy"
        "300": qsTrId("weather-la-description_cloudy"),
        //% "Overcast"
        "400": qsTrId("weather-la-description_overcast"),
        //% "Partly cloudy and light rain"
        "210": qsTrId("weather-la-description_partly_cloudy_and_light_rain"),
        //% "Cloudy and light rain"
        "310": qsTrId("weather-la-description_cloudy_and_light_rain"),
        //% "Overcast and light rain"
        "410": qsTrId("weather-la-description_overcast_and_light_rain"),
        //% "Partly cloudy and showers"
        "220": qsTrId("weather-la-description_partly_cloudy_and_showers"),
        //% "Cloudy and showers"
        "320": qsTrId("weather-la-description_cloudy_and_showers"),
        //% "Overcast and showers"
        "420": qsTrId("weather-la-description_overcast_and_showers"),
        //% "Overcast and rain"
        "430": qsTrId("weather-la-description_overcast_and_rain"),
        //% "Partly cloudy, possible thunderstorms with rain"
        "240": qsTrId("weather-la-description_partly_cloudy_possible_thunderstorms_with_rain"),
        //% "Cloudy, thunderstorms with rain"
        "340": qsTrId("weather-la-description_cloudy_thunderstorms_with_rain"),
        //% "Overcast, thunderstorms with rain"
        "440": qsTrId("weather-la-description_overcast_thunderstorms_with_rain"),
        //% "Partly cloudy and light wet snow"
        "211": qsTrId("weather-la-description_partly_cloudy_and_light_wet_snow"),
        //% "Cloudy and light wet snow"
        "311": qsTrId("weather-la-description_cloudy_and_light_wet_snow"),
        //% "Overcast and light wet snow"
        "411": qsTrId("weather-la-description_overcast_and_light_wet_snow"),
        //% "Partly cloudy and wet snow showers"
        "221": qsTrId("weather-la-description_partly_cloudy_and_wet_snow_showers"),
        //% "Cloudy and wet snow showers"
        "321": qsTrId("weather-la-description_cloudy_and_wet_snow_showers"),
        //% "Overcast and wet snow showers"
        "421": qsTrId("weather-la-description_overcast_and_wet_snow_showers"),
        //% "Overcast and wet snow"
        "431": qsTrId("weather-la-description_overcast_and_wet_snow"),
        //% "Partly cloudy and light snow"
        "212": qsTrId("weather-la-description_partly_cloudy_and_light_snow"),
        //% "Cloudy and light snow"
        "312": qsTrId("weather-la-description_cloudy_and_light_snow"),
        //% "Overcast and light snow"
        "412": qsTrId("weather-la-description_overcast_and_light_snow"),
        //% "Partly cloudy and snow showers"
        "222": qsTrId("weather-la-description_partly_cloudy_and_snow_showers"),
        //% "Cloudy and snow showers"
        "322": qsTrId("weather-la-description_cloudy_and_snow_showers"),
        //% "Overcast and snow showers"
        "422": qsTrId("weather-la-description_overcast_and_snow_showers"),
        //% "Overcast and snow"
        "432": qsTrId("weather-la-description_overcast_and_snow")
    }

    return localizations[code.substr(1,3)]
}
