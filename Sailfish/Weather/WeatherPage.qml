import QtQuick 2.2
import Sailfish.Silica 1.0
import Sailfish.Weather 1.0

Page {
    id: root

    property var weather
    property var weatherModel
    property int currentIndex
    property bool inEventsView
    property bool current

    SilicaFlickable {
        anchors {
            top: parent.top
            bottom: weatherForecastList.top
        }
        clip: true
        width: parent.width
        contentHeight: weatherHeader.height
        VerticalScrollDecorator {}

        PullDownMenu {
            visible: forecastModel.count > 0
            busy: forecastModel.status === Weather.Loading

            MenuItem {
                visible: inEventsView
                //% "Open app"
                text: qsTrId("weather-me-open_app")
                onClicked: launcher.launch()
                WeatherLauncher { id: launcher }
            }
            MenuItem {
                //% "More information"
                text: qsTrId("weather-me-more_information")
                onClicked: Qt.openUrlExternally("http://foreca.mobi/spot.php?l=" + root.weather.locationId)
            }
            MenuItem {
                //% "Update"
                text: qsTrId("weather-me-update")
                onClicked: forecastModel.reload()
            }
        }
        WeatherDetailsHeader {
            id: weatherHeader

            current: root.current
            today: root.currentIndex === 0
            opacity: forecastModel.count > 0 ? 1.0 : 0.0
            weather: root.weather
            status: forecastModel.status
            model: forecastModel.count > 0 ? forecastModel.get(currentIndex) : null
            Behavior on opacity { OpacityAnimator { easing.type: Easing.InOutQuad;  duration: 400 } }
        }
        PlaceholderItem {
            y: Theme.itemSizeSmall + Theme.itemSizeLarge*2
            error: forecastModel.status === Weather.Error
            enabled: forecastModel.count === 0
            onReload: forecastModel.reload()
        }
    }
    SilicaListView {
        id: weatherForecastList

        opacity: forecastModel.count > 0 ? 1.0 : 0.0
        Behavior on opacity { OpacityAnimator { easing.type: Easing.InOutQuad;  duration: 400 } }

        interactive: false
        width: parent.width
        model: WeatherForecastModel {
            id: forecastModel
            weather: root.weather
            timestamp: weatherModel.timestamp
            active: root.status == PageStatus.Active && Qt.application.active
        }

        orientation: ListView.Horizontal
        height: 2*Theme.itemSizeLarge
        anchors.bottom: parent.bottom
        delegate: MouseArea {
            property bool highlighted: (pressed && containsMouse) || root.currentIndex == model.index

            width: root.width/5
            height: weatherForecastList.height

            Rectangle {
                visible: highlighted
                anchors.fill: parent
                gradient: Gradient {
                    GradientStop {
                        position: 0.0
                        color: "transparent"
                    }
                    GradientStop {
                        position: 1.0
                        color: Theme.rgba(Theme.highlightBackgroundColor, 0.3)
                    }
                }
            }
            onClicked: root.currentIndex = model.index
            Column {
                anchors.centerIn: parent
                Label {
                    property bool truncate: implicitWidth > parent.width - Theme.paddingSmall

                    x: truncate ? Theme.paddingSmall : parent.width/2 - width/2
                    width: truncate ? parent.width - Theme.paddingSmall : implicitWidth
                    truncationMode: truncate ? TruncationMode.Fade : TruncationMode.None
                    text: model.index === 0 ?
                              //% "Today"
                              qsTrId("weather-la-today")
                            :
                              //% "ddd"
                              Qt.formatDateTime(timestamp, qsTrId("weather-la-date_pattern_shortweekdays"))
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
                    font.pixelSize: Theme.fontSizeSmall
                }
                Label {
                    text: TemperatureConverter.format(model.high)
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: highlighted ? Theme.highlightColor : Theme.primaryColor
                }
                Image {
                    sourceSize.width: width
                    sourceSize.height: height
                    width: Theme.iconSizeMedium
                    height: Theme.iconSizeMedium
                    anchors.horizontalCenter: parent.horizontalCenter
                    source: model.weatherType.length > 0 ? "image://theme/graphic-weather-" + model.weatherType
                                                            + (highlighted ? "?" + Theme.highlightColor : "")
                                                          : ""
                }
                Label {
                    text: TemperatureConverter.format(model.low)
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
                }
            }
        }
        PanelBackground {
            z: -1
            anchors.fill: parent
        }
    }
}
