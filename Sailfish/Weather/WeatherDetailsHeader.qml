import QtQuick 2.2
import Sailfish.Silica 1.0
import Sailfish.Weather 1.0

Item {
    id: root

    property var model
    property var weather
    property bool today
    property bool current
    property int status

    width: parent.width
    height: childrenRect.height

    Column {
        width: parent.width
        PageHeader {
            id: pageHeader
            title: weather ? weather.city : ""
            description: {
                if (status === Weather.Error) {
                    //% "Loading failed"
                    return qsTrId("weather-la-weather_loading_failed")
                } else if (status === Weather.Loading) {
                    //% "Loading"
                    return qsTrId("weather-la-weather_loading")
                } else if (today) {
                    //% "Weather today"
                    return qsTrId("weather-la-weather_today")
                } else {
                    //% "Weather forecast"
                    return qsTrId("weather-la-weather_forecast")
                }
            }
        }


        Item {
            width: parent.width
            height: windDirectionIcon.height + windDirectionIcon.y

            Label {
                id: accumulatedPrecipitationLabel
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeHuge
                text: model ? parseFloat(model.accumulatedPrecipitation).toLocaleString(Qt.locale(), 'f', 1) : ""
                anchors {
                    verticalCenter: windDirectionIcon.verticalCenter
                    left: Screen.sizeCategory >= Screen.Large ? undefined : parent.left
                    horizontalCenter: Screen.sizeCategory >= Screen.Large ? windDirectionIcon.horizontalCenter : undefined
                    leftMargin: Theme.horizontalPageMargin
                    horizontalCenterOffset: -Screen.width/4
                }
            }
            Label {
                id: precipitationMetricLabel

                anchors {
                    left: accumulatedPrecipitationLabel.right
                    baseline: accumulatedPrecipitationLabel.baseline
                }
                color: Theme.highlightColor
                //: Millimeters, short form
                //% "mm"
                text: qsTrId("weather-la-mm")
                font.pixelSize: Theme.fontSizeExtraSmall
            }
            Label {
                anchors {
                    left: accumulatedPrecipitationLabel.left
                    top: accumulatedPrecipitationLabel.baseline
                    topMargin: Theme.paddingSmall
                }
                width: parent.width/3 - Theme.paddingLarge
                wrapMode: Text.WordWrap
                color: Theme.secondaryHighlightColor
                font.pixelSize: Theme.fontSizeExtraSmall
                //% "Precipitation"
                text: qsTrId("weather-la-precipitation")
            }
            Image {
                id: windDirectionIcon
                y: Screen.sizeCategory >= Screen.Large ? 0 : -Theme.paddingLarge
                source: "image://theme/graphic-weather-wind-direction?" + Theme.highlightColor
                anchors.horizontalCenter: parent.horizontalCenter
                // possible rotation values are 0 and multiplies of 45 degrees
                // once valid value is obtained enable animation on further changes
                rotation: model ? model.windDirection + 180 : -1 // place opposite to indicate where wind is going to
                onRotationChanged: if (rotation !== -1) rotationBehavior.enabled = true
                Behavior on rotation {
                    id: rotationBehavior
                    enabled: false
                    RotationAnimator {
                        duration: 200
                        easing.type: Easing.InOutQuad
                        direction: RotationAnimator.Shortest
                    }
                }
            }
            Label {
                id: windSpeedLabel
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeHuge
                anchors.centerIn: windDirectionIcon
                text: model ? model.windSpeed : ""
            }
            Label {
                anchors {
                    horizontalCenter: windSpeedLabel.horizontalCenter
                    top: windSpeedLabel.baseline
                    topMargin: Theme.paddingSmall
                }

                // TODO: localize
                //: Meters per second, short form
                //% "m/s"
                text: qsTrId("weather-la-m_per_s")
                color: Theme.secondaryHighlightColor
                font.pixelSize: Theme.fontSizeExtraSmall
            }
            Label {
                id: temperatureHighLabel
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeHuge
                text: model ? TemperatureConverter.format(model.high) : ""
                anchors {
                    verticalCenter: windDirectionIcon.verticalCenter
                    right: Screen.sizeCategory >= Screen.Large ? undefined : parent.right
                    horizontalCenter: Screen.sizeCategory >= Screen.Large ? windDirectionIcon.horizontalCenter : undefined
                    rightMargin: Theme.horizontalPageMargin
                    horizontalCenterOffset: Screen.width/4
                }
            }
            Label {
                color: Theme.secondaryHighlightColor
                font.pixelSize: Theme.fontSizeExtraSmall
                anchors {
                    top: temperatureHighLabel.baseline
                    topMargin: Theme.paddingSmall
                    right: temperatureHighLabel.right
                }
                //: Shows daily low temperature as label, e.g. "Low -3°". Degree symbol comes from outside.
                //% "Low %1"
                text: model ? qsTrId("weather-la-daily_low_temperature").arg(TemperatureConverter.format(model.low)) : ""
            }
        }
        Item { width: 1; height: Theme.paddingMedium }
        Label {
            color: Theme.highlightColor
            anchors.horizontalCenter: parent.horizontalCenter
            width: Screen.sizeCategory >= Screen.Large && isPortrait ? Screen.width/2
                                                                     : parent.width - 2*Theme.horizontalPageMargin
            wrapMode: Text.Wrap
            font.pixelSize: Theme.fontSizeLarge
            horizontalAlignment: Text.AlignHCenter
            text: model ? model.description : ""
            height: lineCount === 1 && isPortrait ? 2*implicitHeight : implicitHeight
        }
        Item { width: 1; height: Theme.paddingMedium }
        Grid {
            width: parent.width
            columns: isPortrait ? 1 : 2
            WeatherDetailItem {
                //% "Weather station"
                label: qsTrId("weather-la-weather_station")
                //: Order of weather location string, "State, Country", e.g. "Finland, Helsinki"
                //% "%0, %1"
                value: weather ? (weather.state.length > 0 ? qsTrId("weather-la-weather_station_order")
                                                             .arg(weather.state).arg(weather.country)
                                                           : weather.country) : ""
            }
            WeatherDetailItem {
                //% "Date"
                label: qsTrId("weather-la-weather_date")
                value: {
                    if (model) {
                        var dateString = Format.formatDate(model.timestamp, Format.DateLong)
                        return dateString.charAt(0).toUpperCase() + dateString.substr(1)
                    }
                    return ""
                }
            }
            WeatherDetailItem {
                //% "Cloudiness"
                label: qsTrId("weather-la-cloudiness")
                value: model ? model.cloudiness + Qt.locale().percent : ""
            }
            WeatherDetailItem {
                //% "Precipitation rate"
                label: qsTrId("weather-la-precipitationrate")
                value: model ? model.precipitationRate : ""
            }
            WeatherDetailItem {
                //% "Precipitation type"
                label: qsTrId("weather-la-precipitationtype")
                value: model ? model.precipitationType : ""
            }
        }

        ProviderDisclaimer {
            weather: root.weather
            topMargin: Theme.paddingMedium
            bottomMargin: Theme.paddingLarge
        }
    }
}
