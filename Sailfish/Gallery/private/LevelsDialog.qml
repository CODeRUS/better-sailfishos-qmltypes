/****************************************************************************
**
** Copyright (C) 2016 Jolla Ltd.
** Contact: Matt Vogt <matthew.vogt@jollamobile.com>
**
****************************************************************************/

import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Gallery 1.0

SplitViewDialog {
    id: levelsDialog

    property real brightness
    property real contrast

    property alias foregroundItem: flickable
    property alias foreground: flickable.children

    signal levels(real brightness, real contrast)
    signal levelsRequested
    signal levelsCanceled

    function adjustValue(name, value) {
        if (name == 'brightness') {
            brightness = value
        } else if (name == 'contrast') {
            contrast = value
        } else {
            return
        }

        levels(brightness, contrast)
    }

    onDone: {
        if (result == DialogResult.Accepted) {
            levelsRequested()
        } else {
            levelsCanceled()
        }
    }

    background: SilicaListView {
        anchors.fill: parent

        header: DialogHeader {
            dialog: levelsDialog
        }

        delegate: Column {
            width: parent.width - Theme.horizontalPageMargin*2
            x: Theme.horizontalPageMargin
            spacing: Theme.paddingLarge

            Label {
                color: slider.highlighted ? Theme.highlightColor : Theme.primaryColor
                width: parent.width
                text: model.text
            }

            Slider {
                id: slider

                width: parent.width
                value: initialValue
                maximumValue: maxValue
                minimumValue: minValue
                onValueChanged: levelsDialog.adjustValue(adjustedPropertyName, value)
            }
        }

        model: ListModel {

            function _levelsOption(index) {
                if (_levelsOption["list"] === undefined) {
                    _levelsOption.list = [
                    {
                        //: Adjust the image light levels
                        //% "Light"
                        text: qsTrId("components_gallery-li-light"),
                        adjustedPropertyName: 'brightness',
                        initialValue: 0.0,
                        maxValue: 1.0,
                        minValue: -1.0
                    },
                    {
                        //: Adjust the image contrast level
                        //% "Contrast"
                        text: qsTrId("components_gallery-li-contrast"),
                        adjustedPropertyName: 'contrast',
                        initialValue: 0.0,
                        maxValue: 1.0,
                        minValue: -1.0
                    }]
                }
                return _levelsOption.list[index]
            }

            Component.onCompleted: {
                var index = 0
                for (; index < 2; ++index) {
                    append(_levelsOption(index))
                }
            }
        }
    }

    _foreground: Flickable {
        id: flickable
        anchors.fill: parent
        flickableDirection: levelsDialog.splitOpen ? Flickable.AutoFlickDirection : Flickable.HorizontalAndVerticalFlick
    }

    Binding {
        target: pageStack._pageStackIndicator
        property: "enabled"
        value: levelsDialog.splitOpened
        when: levelsDialog.status === PageStatus.Activating || levelsDialog.status === PageStatus.Active
    }
}
