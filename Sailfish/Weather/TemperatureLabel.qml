import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    property alias temperature: temperatureLabel.text
    property alias feelsLikeTemperature: feelsLikeTemperatureLabel.text
    property alias color: temperatureLabel.color

    height: temperatureLabel.height
    width: temperatureLabel.width + degreeSymbol.width + Theme.paddingMedium
    Label {
        id: temperatureLabel
        color: Theme.primaryColor

        // Glyphs larger than 100 or so look poorly in the default rendering mode
        renderType: font.pixelSize > 100 ? Text.NativeRendering : Text.QtRendering
        font {
            pixelSize: 120*Screen.width/540
            family: Theme.fontFamilyHeading
        }
    }
    Label {
        id: degreeSymbol
        text: "\u00B0"
        color: parent.color
        anchors {
            left: temperatureLabel.right
            leftMargin: Theme.paddingMedium
        }
        font {
            pixelSize: 3*Theme.fontSizeLarge
            family: Theme.fontFamilyHeading
        }
    }
    Label {
        id: feelsLikeTemperatureLabel
        opacity: 0.6
        color: parent.color
        font.pixelSize: Theme.fontSizeLarge
        anchors {
            baseline: temperatureLabel.baseline
            right: degreeSymbol.right
        }
    }
}
