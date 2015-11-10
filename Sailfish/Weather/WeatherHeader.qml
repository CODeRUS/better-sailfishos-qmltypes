import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Weather 1.0

MouseArea {
    id: root

    property var weather
    property bool highlighted: pressed && containsMouse
    property date timestamp: weather ? weather.timestamp : new Date()

    enabled: weather && weather.populated
    width: parent.width
    height: childrenRect.height

    Behavior on height { NumberAnimation { duration: 200; easing.type: Easing.InOutQuad } }
    WeatherImage {
        id: weatherImage
        x: Theme.horizontalPageMargin
        y: 2*Theme.horizontalPageMargin
        highlighted: root.highlighted
        height: sourceSize.height > 0 ? sourceSize.height : 256*Theme.pixelRatio
        weatherType: weather && weather.weatherType.length > 0 ? weather.weatherType : ""
    }
    PageHeader {
        id: pageHeader
        property int offset: _titleItem.y + _titleItem.height
        anchors {
            left: weatherImage.right
            // weather graphics have some inline padding and rounded edges to give space for header
            leftMargin: -Theme.itemSizeMedium
            right: parent.right
        }
        title: weather ? weather.city : ""
    }
    Column {
        id: column
        anchors {
            top: pageHeader.top
            topMargin: pageHeader.offset
            left: weatherImage.right
            right: parent.right
            rightMargin: Theme.horizontalPageMargin
        }

        spacing: -Theme.paddingMedium
        Item {
            width: parent.width
            height: secondaryLabel.height + timestampLabel.height
            Label {
                id: secondaryLabel
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.secondaryHighlightColor
                //% "Current location"
                text: qsTrId("weather-la-current_location")
                horizontalAlignment: Text.AlignRight
                wrapMode: Text.Wrap
                width: parent.width
            }
            Label {
                id: timestampLabel
                width: parent.width
                wrapMode: Text.Wrap
                anchors.top: secondaryLabel.bottom
                font.pixelSize: Theme.fontSizeSmall
                horizontalAlignment: Text.AlignRight
                color: Theme.secondaryHighlightColor
                text: Format.formatDate(timestamp, Format.TimeValue)
            }
        }
        TemperatureLabel {
            anchors.right: parent.right
            temperature: weather ? TemperatureConverter.formatWithoutUnit(weather.temperature) : ""
            temperatureFeel: weather ? TemperatureConverter.formatWithoutUnit(weather.temperatureFeel) : ""
            color: highlighted ? Theme.highlightColor : Theme.primaryColor
        }
    }
    Label {
        anchors {
            top: column.bottom
            topMargin: -Theme.paddingMedium
            left: parent.left
            right: parent.right
            leftMargin: Theme.horizontalPageMargin
            rightMargin: Theme.horizontalPageMargin
        }
        color: highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
        font {
            pixelSize: Theme.fontSizeExtraLarge
            family: Theme.fontFamilyHeading
        }
        wrapMode: Text.Wrap
        horizontalAlignment: Text.AlignRight
        text: weather ? weather.description : ""
    }
}
