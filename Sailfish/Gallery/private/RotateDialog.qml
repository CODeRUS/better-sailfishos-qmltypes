/****************************************************************************
**
** Copyright (C) 2013 Jolla Ltd.
** Contact: Marko Mattila <marko.mattila@jollamobile.com>
**
****************************************************************************/

import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Gallery 1.0

SplitViewDialog
{
    id: rotateDialog

    property real rotationAngle

    signal rotate(real angle)
    signal rotateRequested
    signal rotateCanceled

    onDone: {
        if (result == DialogResult.Accepted) {
            rotateRequested()
        } else {
            rotateCanceled()
        }
    }

    background: SilicaListView {
        anchors.fill: parent

        header: DialogHeader {
            dialog: rotateDialog
        }

        delegate: BackgroundItem {
            id: operationDelegate

            IconButton {
                id: icon
                x: Theme.paddingLarge
                icon.source: model.icon
                icon.opacity: 1.0
                down: operationDelegate.highlighted
                enabled: false
                anchors.verticalCenter: parent.verticalCenter
            }

            Label {
                color: highlighted ? Theme.highlightColor : Theme.primaryColor
                text: model.text
                anchors {
                    left: icon.right
                    right: parent.right
                    rightMargin: Theme.paddingLarge
                    verticalCenter: parent.verticalCenter
                }
            }

            onClicked: {
                rotateDialog.rotationAngle += angle
                rotateDialog.rotate(angle)
            }
        }

        model: ListModel {

            function _rotationOption(index) {
                if (_rotationOption["list"] === undefined) {
                    _rotationOption.list = [
                    {
                        //: Rotate image 90 degrees clockwise
                        //% "Rotate right"
                        text: qsTrId("components_gallery-li-rotate_right"),
                        angle: 90,
                        icon: "image://theme/icon-m-rotate-right"
                    },
                    {
                        //: Rotate image 90 degrees counter clockwise
                        //% "Rotate left"
                        text: qsTrId("components_gallery-li-rotate_left"),
                        angle: -90,
                        icon: "image://theme/icon-m-rotate-left"
                    }]
                }
                return _rotationOption.list[index]
            }

            Component.onCompleted: {
                var index = 0
                for (; index < 2; ++index) {
                    append(_rotationOption(index))
                }
            }
        }
    }
    Binding {
        target: pageStack._pageStackIndicator
        property: "enabled"
        value: rotateDialog.splitOpened
        when: rotateDialog.status === PageStatus.Activating || rotateDialog.status === PageStatus.Active
    }
}
