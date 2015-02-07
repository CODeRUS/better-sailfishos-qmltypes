import QtQuick 2.1
import Sailfish.Silica 1.0
import com.jolla.gallery.ambience 1.0

Item {
    id: colorEditor

    property QtObject colorSettings
    property bool activeAmbience
    property real leftMargin

    width: parent.width
    height: column.height

    onColorSettingsChanged: {
        highlightColor.color = colorSettings.highlightColor
        highlightSlider.value = highlightColor.hue
    }

    Color {
        id: highlightColor

        onHueChanged: colorSettings.highlightColor = color
        onLightnessChanged: colorSettings.highlightColor = color
    }

    Column {
        id: column

        width: parent.width
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: Theme.paddingLarge

        Row {
            x: Theme.paddingLarge
            spacing: Theme.paddingSmall
            Item {
                // For aligning the preview rect with the arrow icon of "Appearance" label
                width: Theme.iconSizeMedium
                height: Theme.paddingLarge
                Rectangle {
                    id: preview
                    color: highlightColor.color
                    width: Theme.paddingLarge
                    height: width
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
            Label {
                //: Text to indicate color changes
                //% "Refined color"
                text: qsTrId("jolla-gallery-ambience-la-refined-color")
                color: highlightColor.color
                height: preview.height
                verticalAlignment: Text.AlignVCenter
            }
        }

        ColorSlider {
            id: highlightSlider
            minimumValue: 0
            maximumValue: 1
            stepSize: 0.01
            value: highlightColor.hue
            lightness: highlightColor.lightness
            saturation: highlightColor.saturation
            onValueChanged: highlightColor.hue = value
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width - Theme.paddingLarge
            leftMargin: colorEditor.leftMargin

            //: Highlight color for ambience
            //% "Active"
            label: qsTrId("jolla-gallery-ambience-la-active-color")
        }
    }

}
