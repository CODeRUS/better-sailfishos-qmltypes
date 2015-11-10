import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Weather 1.0

Column {
    property bool loading: forecastModel.status == Weather.Loading && forecastModel.count === 0

    property real dataOpacity: forecastModel.status == Weather.Ready && forecastModel.count > 0 ? 1.0 : 0.0
    Behavior on dataOpacity { FadeAnimation { property: "dataOpacity" } }

    height: parent.height

    Item {
        x: Theme.horizontalPageMargin-Theme.paddingLarge
        width: parent.width - 2*x
        height: parent.height - providerDisclaimer.height

        Column {
            id: contentArea

            y: (parent.height - height) / 2
            width: parent.width
            spacing: Theme.paddingSmall

            property bool retryLoad

            visible: opacity > 0
            opacity: !retryLoad && forecastModel.status == Weather.Error ? 1 : 0
            Behavior on opacity {
                FadeAnimation {
                    onRunningChanged: {
                        if (!running && contentArea.retryLoad) {
                            forecastModel.reload()
                            contentArea.retryLoad = false
                        }
                    }
                }
            }

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                //% "No network"
                text: qsTrId("weather-la-no_network")
                color: Theme.highlightColor
                font {
                    pixelSize: Theme.fontSizeMedium
                    family: Theme.fontFamilyHeading
                }
            }
            BackgroundItem {
                Label {
                    anchors.centerIn: parent
                    //% "Retry"
                    text: qsTrId("weather-la-retry")
                    color: parent.down ? Theme.highlightColor : Theme.primaryColor
                    font.pixelSize: Theme.fontSizeMedium
                }
                onClicked: contentArea.retryLoad = true
            }
        }

        SilicaListView {
            id: weatherForecastList

            anchors.fill: parent
            clip: true // limit to five day forecast
            currentIndex: -1
            interactive: false
            orientation: ListView.Horizontal
            model: WeatherForecastModel {
                id: forecastModel
                active: weatherBanner.expanded
                weather: weatherBanner.weather
                timestamp: weatherModel.timestamp
            }
            delegate: Item {
                width: weatherForecastList.width/5
                height: weatherForecastList.height
                WeatherForecastItem { id: forecastItem }
            }
            opacity: dataOpacity
        }
    }

    MouseArea {
        id: providerDisclaimer

        property bool down: pressed && containsMouse

        onClicked: Qt.openUrlExternally("http://foreca.mobi/spot.php?l=" + savedWeathersModel.currentWeather.locationId)

        width: row.width
        height: row.height + Theme.paddingSmall
        anchors { right: parent.right; rightMargin: Theme.horizontalPageMargin }
        enabled: weatherBanner.expanded && savedWeathersModel.currentWeather && savedWeathersModel.currentWeather.populated
        Row {
            id: row

            spacing: Theme.paddingMedium
            Label {
                //% "Powered by"
                text: qsTrId("weather-la-powered_by")
                font.pixelSize: Theme.fontSizeTiny
                anchors.verticalCenter: parent.verticalCenter
                color: highlighted || providerDisclaimer.down ? Theme.secondaryHighlightColor : Theme.secondaryColor
            }
            Image {
                // TODO: replace with properly-sized icon from design
                anchors.verticalCenter: parent.verticalCenter
                source: "image://theme/graphic-foreca-small?" + (highlighted || providerDisclaimer.down ? Theme.highlightColor : Theme.primaryColor)
            }
        }
        opacity: dataOpacity
    }
}

