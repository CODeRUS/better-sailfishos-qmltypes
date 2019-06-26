import QtQuick 2.0
import Sailfish.Silica 1.0

AmbienceAction {
    id: action

    property int defaultVolume

    function hasValue(ambience) {
        return ambience[property] >= 0
    }
    function clearValue(ambience) {
        ambience[property] = -1;
    }
    function setDefaultValue(ambience) {
        ambience[property] = defaultVolume
    }

    editor: Item {
        id: editor

        height: slider.y + slider.height

        property color primaryColor: Theme.primaryColor
        property color secondaryColor: Theme.secondaryColor
        property color highlightColor: Theme.highlightColor
        property color secondaryHighlightColor: Theme.secondaryHighlightColor
        property int colorScheme: Theme.colorScheme
        property int volume: ambience[action.property]
        onVolumeChanged: slider.value = volume

        Label {
            anchors {
                left: editor.left
                leftMargin: Theme.horizontalPageMargin
                right: editor.right
                rightMargin: Theme.horizontalPageMargin + Theme.itemSizeSmall + Theme.paddingMedium
                verticalCenter: editor.top
                verticalCenterOffset: Theme.itemSizeSmall / 2
            }
            color: editor.highlightColor
            text: action.label
        }

        Slider {
            id: slider

            y: Theme.itemSizeSmall
            width: editor.width
            height: implicitHeight + valueLabel.height
            colorScheme: editor.colorScheme
            highlightColor: editor.highlightColor
            backgroundColor: editor.secondaryColor
            secondaryHighlightColor: editor.secondaryHighlightColor
            backgroundGlowColor: slider.colorScheme === Theme.DarkOnLight
                        ? Theme.highlightDimmerFromColor(editor.highlightColor, editor.colorScheme)
                        : "transparent"
            minimumValue: 0
            maximumValue: 100
            stepSize: 20

            onValueChanged: ambience[action.property] = Math.round(value)

            Label {
                id: valueLabel
                //: Volume as a percentage.
                //% "%1%"
                text: slider.value > 0
                        ? qsTrId("jolla-gallery-ambience-sound-la-volume_text").arg(slider.value)
                        : ""
                x: slider.leftMargin - width/2
                anchors.bottom: parent.verticalCenter // assuming slider centers its content vertically
                anchors.bottomMargin: Theme.paddingSmall + Theme.paddingMedium
                scale: slider.down ? Theme.fontSizeLarge / Theme.fontSizeMedium : 1.0
                color: slider.highlighted ? editor.highlightColor : editor.primaryColor

                Behavior on scale { NumberAnimation { duration: 80 } }

                Image {
                    source: "image://theme/icon-status-silent" + (slider.highlighted ? ("?" + editor.highlightColor) : "")
                    visible: slider.value === 0
                    anchors.centerIn: parent
                }
            }
        }
    }
}
