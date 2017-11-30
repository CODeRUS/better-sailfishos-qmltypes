import QtQuick 2.0
import Sailfish.Silica 1.0

BackgroundItem {
    id: root

    property var weather
    property int topMargin: Theme.paddingLarge
    property int bottomMargin: 2*Theme.paddingLarge

    onClicked: if (weather) Qt.openUrlExternally("http://foreca.mobi/spot.php?l=" + weather.locationId)
    height: column.height + topMargin + bottomMargin
    Column {
        id: column
        width: parent.width
        spacing: Theme.paddingSmall
        Label {
            //% "Powered by"
            text: qsTrId("weather-la-powered_by")
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: Theme.fontSizeTiny
            color: highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
        }
        Image {
            anchors.horizontalCenter: parent.horizontalCenter
            source: "image://theme/graphic-foreca-large?" + (highlighted ? Theme.highlightColor : Theme.primaryColor)
        }
        anchors {
            bottom: parent.bottom
            bottomMargin: root.bottomMargin
        }
    }
}
