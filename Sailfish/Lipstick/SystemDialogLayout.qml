/****************************************************************************
**
** Copyright (C) 2013 Jolla Ltd.
** Contact: Petri M. Gerdt <petri.gerdt@jollamobile.com>
**
****************************************************************************/

import QtQuick 2.0
import Sailfish.Silica 1.0
import org.nemomobile.configuration 1.0

Item {
    id: layout

    property alias title: label.text
    property alias buttons: buttonsContainer.children
    property alias selectedButton: buttonsContainer.selectedItem

    default property alias _data: content.data

    property int _screenRotation: screenConfig.value != undefined ? screenConfig.value : 0
    property bool _transpose: (_screenRotation % 180) != 0
    property real _imMargin: _transpose
                ? Qt.inputMethod.keyboardRectangle.width
                : Qt.inputMethod.keyboardRectangle.height
    property real _contentHeight: content.y + content.height
    property real _maximumHeight: Math.min(
                layout._contentHeight,
                Math.min(Screen.height * 2.0 / 3.0, Screen.height - layout._imMargin))

    property alias contentWidth: content.width
    property alias contentHeight: content.height

    implicitWidth: _transpose ? _maximumHeight : Screen.width
    implicitHeight: _transpose ? Screen.width : _maximumHeight

    Behavior on _imMargin {
        NumberAnimation {
            duration: 200
            easing.type: Easing.InOutQuad
        }
    }

    ConfigurationValue {
        id: screenConfig
        key: "/desktop/jolla/components/screen_rotation_angle"
    }

    SilicaFlickable {
        id: flickable

        clip: contentHeight > height

        width: layout._transpose ? layout.height : layout.width
        height: layout._transpose ? layout.width : layout.height

        rotation: 0 - layout._screenRotation

        anchors.centerIn: layout

        contentWidth: flickable.width
        contentHeight: layout._contentHeight

        Label {
            id: label

            y: Theme.paddingLarge
            width: flickable.width

            font {
                family: Theme.fontFamilyHeading
                pixelSize: Theme.fontSizeMedium
            }

            horizontalAlignment: Text.AlignHCenter
            color: "black"
            opacity: 0.6
            wrapMode: Text.Wrap
        }


        Image {
            id: highlightBackground
            visible: buttonsContainer.visible
            anchors { fill: buttonsContainer }
            rotation: 180

            source: "image://theme/graphic-system-gradient?" + Theme.highlightColor
        }

        Row {
            id: buttonsContainer

            property Item selectedItem
            property real itemWidth: children.length > 0 ? width / children.length : 0

            anchors.top: label.bottom

            width: flickable.width
            height: visible ? Math.floor(Screen.height / 3) - y : 0

            visible: children.length > 0
        }

        Rectangle {
            anchors.fill: content

            color: Theme.highlightBackgroundColor
        }

        Item {
            id: content

            anchors.top: buttonsContainer.bottom

            implicitWidth: flickable.width
        }
    }
}
