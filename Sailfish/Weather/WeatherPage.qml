import QtQuick 2.2
import Sailfish.Silica 1.0
import Sailfish.Weather 1.0

Page {
    id: root

    property var weather
    property var weatherModel
    property int currentIndex
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

    PanelBackground {
        width: parent.width
        height: weatherForecastList.height
        anchors.bottom: parent.bottom
        opacity: forecastModel.count > 0 ? 1.0 : 0.0
        Behavior on opacity { OpacityAnimator { easing.type: Easing.InOutQuad;  duration: 400 } }
    }
    SilicaListView {
        id: weatherForecastList
        opacity: forecastModel.count > 0 ? 1.0 : 0.0
        Behavior on opacity { OpacityAnimator { easing.type: Easing.InOutQuad;  duration: 400 } }

        interactive: false
        property int itemWidth: Screen.sizeCategory >= Screen.Large ? Screen.width/7 : Screen.width/5
        width: 5*itemWidth
        model: WeatherForecastModel {
            id: forecastModel
            weather: root.weather
            timestamp: weatherModel.timestamp
            active: root.status == PageStatus.Active && Qt.application.active
        }

        clip: true
        orientation: ListView.Horizontal
        height: 2*(Screen.sizeCategory >= Screen.Large ? Theme.itemSizeExtraLarge : Theme.itemSizeLarge)
        anchors {
            bottom: parent.bottom
            horizontalCenter: parent.horizontalCenter
        }
        delegate: MouseArea {
            property bool highlighted: (pressed && containsMouse) || root.currentIndex == model.index

            width: weatherForecastList.itemWidth
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
            WeatherForecastItem {}
        }
    }
}

