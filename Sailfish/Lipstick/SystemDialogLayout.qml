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
    property alias selectedButton: buttonsContainer.selectedButton

    default property alias _data: content.data

    property alias contentWidth: content.width
    property alias contentHeight: content.height

    property real maximumHeight: layout.height * 2 / 3
    property int headerLayout: Qt.Vertical
    property int buttonCount: buttonsContainer.children.length

    signal dismiss

    SilicaFlickable {
        id: flickable

        clip: contentHeight > height

        width: parent.width
        height: Math.min(layout.maximumHeight, content.y + content.height)

        contentWidth: layout.width
        contentHeight: content.y + content.height

        Rectangle {
            anchors.fill: parent
            color: Theme.highlightBackgroundColor
        }

        Rectangle {
            anchors.fill: content
            color: Theme.rgba(Theme.highlightDimmerColor, 0.2)
        }

        Flow {
            id: header
            x: -flickable.contentX
            width: layout.width

            Item {
                id: labelContainer

                width: buttonsContainer.width
                height: label.y + label.height
                Label {
                    id: label

                    y: Theme.paddingLarge

                    anchors {
                        left: labelContainer.left
                        right: labelContainer.right
                        margins: Theme.horizontalPageMargin
                    }

                    font {
                        family: Theme.fontFamilyHeading
                        pixelSize: Theme.fontSizeMedium
                    }

                    horizontalAlignment: layout.headerLayout == Qt.Vertical
                            ? Text.AlignHCenter
                            : Text.AlignLeft
                    color: Theme.rgba("black", 0.4)
                    wrapMode: Text.Wrap
                }
            }

            Row {
                id: buttonsContainer

                property Item selectedButton
                property real buttonWidth: layout.buttonCount > 0 ? width / layout.buttonCount : 0

                width: layout.headerLayout == Qt.Vertical ? header.width : header.width / 2
                visible: children.length > 0
            }
        }

        Item {
            id: content

            anchors.top: header.bottom

            implicitWidth: flickable.width
        }
    }

    Image {
        id: dimmer
        anchors {
            top: flickable.bottom
            bottom: parent.bottom
        }
        width: parent.width

        source: "image://theme/graphic-system-gradient?" + Theme.highlightBackgroundColor

        MouseArea {
            anchors.fill: dimmer
            onClicked: layout.dismiss()
        }
    }

}
