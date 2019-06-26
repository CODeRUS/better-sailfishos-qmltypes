import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Weather 1.0

Row {
    id: root

    property alias weather: savedWeathersModel.currentWeather
    property alias autoRefresh: savedWeathersModel.autoRefresh
    property alias active: weatherModel.active
    property alias temperatureFont: temperatureLabel.font

    anchors.horizontalCenter: parent.horizontalCenter
    height: image.height
    spacing: Theme.paddingMedium
    visible: !!weather

    Image {
        id: image
        anchors.verticalCenter: parent.verticalCenter
        source: weather && weather.weatherType.length > 0
                ? "image://theme/graphic-m-weather-" + weather.weatherType
                : ""
        // JB#43864 don't yet have weather graphics in small-plus size, so set size manually
        sourceSize.width: Theme.iconSizeSmallPlus
        sourceSize.height: Theme.iconSizeSmallPlus
    }

    Label {
        id: temperatureLabel
        anchors.verticalCenter: image.verticalCenter
        text: weather ? TemperatureConverter.format(weather.temperature) : ""
        color: Theme.primaryColor
        font {
            pixelSize: Theme.fontSizeExtraLarge
            family: Theme.fontFamilyHeading
        }
    }

    SavedWeathersModel {
        id: savedWeathersModel
        autoRefresh: true
    }

    WeatherModel {
        id: weatherModel
        weather: savedWeathersModel.currentWeather
        savedWeathers: savedWeathersModel
    }
}
