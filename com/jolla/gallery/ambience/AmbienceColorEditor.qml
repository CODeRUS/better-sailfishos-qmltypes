import QtQuick 2.1
import Sailfish.Silica 1.0
import com.jolla.gallery.ambience 1.0

Item {
    id: colorEditor

    property QtObject colorSettings
    property bool activeAmbience
    property real leftMargin
    property color _originalColor
    property bool _completed

    width: parent.width
    height: column.height

    onColorSettingsChanged: {
        _originalColor = colorSettings.highlightColor
        highlightColor.color = colorSettings.highlightColor
        highlightSlider.value = highlightColor.hue
    }

    Component.onCompleted: _completed = true

    Color {
        id: highlightColor

        onColorChanged: {
            if (_completed) {
                colorSettings.highlightColor = color
            }
        }
    }

    Column {
        id: column

        width: parent.width
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: Theme.paddingLarge

        Item {
            width: column.width
            height: Theme.itemSizeMedium

            Image {
                id: icon
                anchors {
                    left: parent.left
                    leftMargin: isPortrait ? Theme.horizontalPageMargin : Theme.paddingLarge
                    verticalCenter: parent.verticalCenter
                }
                source: "image://theme/icon-m-dot?" + (mouseArea.down ? _originalColor : highlightColor.color)
            }

            Text {
                anchors {
                    left: icon.right
                    leftMargin: Theme.paddingSmall
                    right: parent.right
                    rightMargin: Theme.horizontalPageMargin
                    verticalCenter: parent.verticalCenter
                }
                //: Text to indicate color changes
                //% "Refined color"
                text: qsTrId("jolla-gallery-ambience-la-refined-color")
                color: mouseArea.down ? _originalColor : highlightColor.color
                font.pixelSize: Theme.fontSizeMedium
                wrapMode: Text.Wrap

                Label {
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: parent.bottom
                    }
                    //: Text to indicate color changes
                    //% "Tap to reset"
                    text: qsTrId("jolla-gallery-ambience-la-reset-color")
                    color: Theme.rgba((mouseArea.down ? _originalColor : highlightColor.color), 0.7)
                    opacity: mouseArea.enabled ? 1.0 : 0.0
                    font.pixelSize: Theme.fontSizeSmall
                    wrapMode: Text.Wrap

                    Behavior on opacity { FadeAnimation {} }
                }
            }

            MouseArea {
                id: mouseArea

                property bool down: pressed && containsMouse

                anchors.fill: parent
                enabled: {
                    var dummy = highlightColor.color // creates a binding
                    return !highlightColor.equals(_originalColor)
                }
                onClicked: {
                    highlightColor.color = _originalColor
                    highlightSlider.value = highlightColor.hue
                }
            }
        }

        ColorSlider {
            id: highlightSlider
            minimumValue: 0
            maximumValue: 1
            stepSize: 0.01
            value: highlightColor.hue
            lightness: 0.5
            saturation: 1.0
            onValueChanged: {
                if (highlightColor.hue !== value) {
                    highlightColor.hue = value
                    highlightColor.remap()
                }
            }
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width - Theme.paddingLarge
            leftMargin: colorEditor.leftMargin

            //: Highlight color for ambience
            //% "Ambience color"
            label: qsTrId("jolla-gallery-ambience-la-ambience-color")
        }
    }

}
