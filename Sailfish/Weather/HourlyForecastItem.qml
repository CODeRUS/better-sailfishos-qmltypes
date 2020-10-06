import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Weather 1.0

Column {
    width: parent.width
    property bool highlighted
    property int hourMode: DateTime.TwentyFourHours

    Item {
        property int padding: Theme.paddingSmall
        width: temperatureLabel.width
        height: temperatureGraph.height + temperatureLabel.height + padding
        anchors.horizontalCenter: parent.horizontalCenter
        Label {
            id: temperatureLabel
            text: TemperatureConverter.format(model.temperature)
            color: highlighted ? Theme.highlightColor : Theme.primaryColor
            y: (1 - model.relativeTemperature) * temperatureGraph.height - parent.padding
        }
    }

    Image {
        property string prefix: "image://theme/icon-" + (Screen.sizeCategory >= Screen.Large ? "l" : "m")
        anchors.horizontalCenter: parent.horizontalCenter
        source: model.weatherType.length > 0 ? prefix + "-weather-" + model.weatherType
                                               + (highlighted ? "?" + Theme.highlightColor : "")
                                             : ""
    }

    Row {
        id: timeRow
        anchors.horizontalCenter: parent.horizontalCenter
        Label {
            id: timeLabel
            text: {
                if (hourMode === DateTime.TwentyFourHours) {
                    return Format.formatDate(model.timestamp, Format.TimeValueTwentyFourHours)
                } else {
                    return Qt.formatTime(model.timestamp, "hh")
                }
            }
            font.pixelSize: hourMode === DateTime.TwentyFourHours ? Theme.fontSizeSmall : Theme.fontSizeMedium
        }
        Label {
            visible: hourMode === DateTime.TwelveHours
            //: Short postfix shown behind hours in twelve hour mode, e.g. time is 8am
            //: Align with jolla-clock-la-am
            //% "AM"
            text: model.timestamp.getHours() < 12 ? qsTrId("weather-la-hourmode_am")
                                                    //: Short postfix shown behind hours in twelve hour mode, e.g. 3pm time
                                                    //: Align with jolla-clock-la-pm
                                                    //% "PM"
                                                  : qsTrId("weather-clock-la-hourmode_pm")
            color: highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
            font.pixelSize: Theme.fontSizeTiny
            anchors.baseline: timeLabel.baseline

        }
    }
}
