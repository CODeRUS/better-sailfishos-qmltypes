import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Weather 1.0

BackgroundItem {
    id: weatherBanner

    property alias weather: savedWeathersModel.currentWeather
    property alias autoRefresh: savedWeathersModel.autoRefresh
    property alias active: weatherModel.active
    property bool expanded

    onActiveChanged: if (!active) save()

    function reload() {
        weatherModel.reload()
    }
    function save() {
        savedWeathersModel.save()
    }

    visible: enabled
    height: enabled ? column.height : 0
    enabled: weather && weather.populated

    onClicked: {
        var alreadyOpened = !!forecastLoader.item
        expanded = !expanded
        weatherModel.attemptReload()
        if (expanded && alreadyOpened) forecastLoader.item.attemptReload()
    }

    Column {
        id: column
        width: parent.width
        Row {
            id: row
            spacing: Theme.paddingMedium
            anchors.horizontalCenter: parent.horizontalCenter
            height: Theme.itemSizeSmall
            Image {
                id: image
                width: height
                height: parent.height
                anchors.verticalCenter: parent.verticalCenter
                source: weather && weather.weatherType.length > 0 ? "image://theme/icon-l-weather-" + weather.weatherType
                                                                    + (highlighted ? ("?" + Theme.highlightColor) : "")
                                                                  : ""
            }
            Label {
                text: weather ? weather.city : ""
                color: highlighted ? Theme.highlightColor : Theme.primaryColor
                font {
                    pixelSize: Theme.fontSizeLarge
                    family: Theme.fontFamilyHeading
                }
                anchors.verticalCenter: parent.verticalCenter
                truncationMode: TruncationMode.Fade
                width: Math.min(implicitWidth, column.width - 4*row.spacing - image.width - temperatureLabel.width)
            }
            Label {
                id: temperatureLabel
                text: weather ? TemperatureConverter.format(weather.temperature) : ""
                color: highlighted ? Theme.highlightColor : Theme.primaryColor
                font {
                    pixelSize: Theme.fontSizeLarge
                    family: Theme.fontFamilyHeading
                }
                anchors.verticalCenter: parent.verticalCenter
            }
        }
        Loader {
            id: forecastLoader
            height: 0
            opacity: 0.0
            active: false
            width: parent.width
            asynchronous: true
            property int contentHeight: Math.max(item ? item.contentHeight : 0, defaultHeight)
            property int defaultHeight: 2*(Screen.sizeCategory >= Screen.Large ? Theme.itemSizeExtraLarge : Theme.itemSizeLarge)

            source: "WeatherBannerForecast.qml"
            onLoaded: item.highlighted = Qt.binding( function () { return weatherBanner.highlighted })
            states: State {
                name: "expanded"
                when: weatherBanner.expanded
                PropertyChanges {
                    target: forecastLoader
                    opacity: 1.0
                    height: forecastLoader.contentHeight
                }
            }
            transitions: [
                Transition {
                    to: "expanded"
                    SequentialAnimation {
                        NumberAnimation {
                            property: "height"
                            duration: 200
                            easing.type: Easing.InOutQuad
                        }
                        FadeAnimation {}
                        ScriptAction {
                            script: forecastLoader.active = true
                        }
                    }
                },
                Transition {
                    to: ""
                    SequentialAnimation {
                        FadeAnimation {}
                        NumberAnimation {
                            property: "height"
                            duration: 200
                            easing.type: Easing.InOutQuad
                        }
                    }
                }

            ]
            BusyIndicator {
                size: Screen.sizeCategory >= Screen.Large ? BusyIndicatorSize.Large : BusyIndicatorSize.Medium
                anchors.centerIn: parent
                running: forecastLoader.item && forecastLoader.item.loading
            }
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
