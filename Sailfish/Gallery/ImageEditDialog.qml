/****************************************************************************
**
** Copyright (C) 2013 Jolla Ltd.
** Contact: Raine Mäkeläinen <raine.makelainen@jollamobile.com>
**
****************************************************************************/

import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Silica.private 1.0
import Sailfish.Gallery 1.0
import Sailfish.Gallery.private 1.0
import Nemo.Notifications 1.0
import "private"

Dialog {
    id: root

    property alias title: titleLabel.text
    property alias source: previewImage.source
    property alias target: previewImage.target

    property bool cropOnly
    property alias aspectRatio: previewImage.aspectRatio
    property alias aspectRatioType: previewImage.aspectRatioType

    property alias brightness: previewImage.previewBrightness
    property alias contrast: previewImage.previewContrast
    property alias imageRotation: previewImage.previewRotation

    property bool _lightAndContrastMode
    property bool _cropMenu
    property string _cropType: "none"
    property int _cropRatio: cropOnly ? aspectRatio : -1.0
    property bool _checkRotation
    property bool _checkLevels
    property bool _checkCrop
    property bool editInProgress
    property bool editSuccessful

    signal edited
    signal finished

    canAccept: imageRotation !== 0 || brightness !== 0 || contrast !== 0 || (_cropType !== "none" || cropOnly)
    backNavigation: !_cropMenu
    forwardNavigation: !_cropMenu

    // JB#44195: Page is inactive, but the page transition is ongoing. Delay page operation a bit
    onStatusChanged: if (status == PageStatus.Inactive) delayedCompletion.restart()

    onIsPortraitChanged: previewImage.resetZoom()

    onAccepted: {
        editInProgress = true
        editStep()
    }

    function editStep() {
        if (!editInProgress) return

        if (!_checkCrop) {
            _checkCrop = true
            if (_cropRatio >= 0) {
                previewImage.crop()
                return
            }
        }

        if (!_checkRotation) {
            _checkRotation = true
            if (imageRotation !== 0) {
                previewImage.rotateImage()
                return
            }
        }

        if (!_checkLevels) {
            _checkLevels = true
            if (brightness !== 0 || contrast !== 0) {
                previewImage.adjustLevels()
                return
            }
        }

        if (_checkCrop && _checkRotation && _checkLevels) {
            editSuccessful = true
            editInProgress = false
            if (status == PageStatus.Inactive) {
                finished()
                edited()
            }
        }
    }

    Timer {
        id: delayedCompletion
        interval: 16
        onTriggered: {
            if (!editInProgress) finished()
            if (editSuccessful) edited()
        }
    }

    FadeBlocker {
        z: -1
        anchors.fill: parent
    }

    Column {
        anchors.fill: parent
        DialogHeader {
            id: header

            //% "Save"
            acceptText: qsTrId("components_gallery-he-save")
            spacing: 0
        }
        ImageEditPreview {
            id: previewImage

            cropOnly: root.cropOnly
            isPortrait: root.isPortrait
            width: parent.width
            height: parent.height - header.height
            active: true
            onEdited: editStep()
            onFailed: {
                //% "Editing image failed"
                errorNotification.previewBody = qsTrId("components_gallery-la-editing_image_failed")
                errorNotification.publish()
                root.editInProgress = false
                finished()
            }

            FadeGradient {
                z: 1
                topDown: true
                width: parent.width
                height: titleLabel.height + 2 * titleLabel.y
                visible: !previewImage.longPressed && !_cropMenu

                Label {
                    id: titleLabel
                    y: Theme.paddingLarge
                    //% "Edit photo"
                    text: qsTrId("sailfish-components-gallery-he-edit_photo")
                    width: parent.width - x
                    x: Theme.horizontalPageMargin
                    font.pixelSize: Theme.fontSizeExtraLarge
                    color: Theme.highlightFromColor(Theme.highlightColor, Theme.LightOnDark)
                    wrapMode: Text.Wrap
                }
            }
        }
    }

    Item {
        id: overlay

        visible: !previewImage.longPressed && !cropOnly
        anchors.fill: parent

        FadeGradient {
            width: parent.width
            height: toolbar.height + 2 * toolbar.anchors.bottomMargin
                    + (slidersLoader.enabled ? slidersLoader.height + slidersLoader.anchors.bottomMargin : 0)
            Behavior on height { NumberAnimation { duration: 200; easing.type: Easing.InOutQuad } }
            anchors.bottom: parent.bottom
        }

        Loader {
            id: slidersLoader
            Behavior on opacity { FadeAnimator {}}
            opacity: enabled ? 1.0 : 0.0
            active: _lightAndContrastMode
            enabled: _lightAndContrastMode
            onActiveChanged: if (active) active = true // remove binding
            anchors {
                bottom: toolbar.top
                bottomMargin: isPortrait ? Theme.paddingLarge : 0
                horizontalCenter: parent.horizontalCenter
            }
            sourceComponent: Column {
                width: root.width

                LevelsSlider {
                    //% "Brightness"
                    label: qsTrId("components_gallery-la-brightness")
                    onValueChanged: brightness = value
                    onDownChanged: previewImage.animatingBrightnessContrast = down
                    onReset: value = 0.0
                }

                LevelsSlider {
                    //% "Contrast"
                    label: qsTrId("components_gallery-la-contrast")
                    onValueChanged: contrast = value
                    onDownChanged: previewImage.animatingBrightnessContrast = down
                    onReset: value = 0.0
                }
            }
        }

        Row {
            id: toolbar
            anchors  {
                bottom: parent.bottom
                bottomMargin: Theme.paddingLarge
                horizontalCenter: parent.horizontalCenter
            }
            spacing: Theme.paddingLarge

            IconButton {
                icon.source: "image://theme/icon-m-rotate-right?" + Theme.lightPrimaryColor
                onClicked: previewImage.previewRotate(90)
            }
            IconButton {
                icon.source: "image://theme/icon-m-rotate-left?" + Theme.lightPrimaryColor
                onClicked: previewImage.previewRotate(-90)
            }
            IconButton {
                icon.source: "image://theme/icon-m-light-contrast?" + Theme.lightPrimaryColor
                onClicked: {
                    _lightAndContrastMode = !_lightAndContrastMode
                }
            }
            IconButton {
                icon.source: "image://theme/icon-m-crop?" + Theme.lightPrimaryColor
                onClicked: {
                    _cropMenu = true
                    _lightAndContrastMode = false
                }
            }
        }
    }

    Loader {
        Behavior on opacity { FadeAnimator {}}
        opacity: enabled ? 1.0 : 0.0
        active: _cropMenu
        enabled: _cropMenu
        anchors.fill: parent
        onActiveChanged: if (active) active = true // remove binding
        sourceComponent: CropMenu {
            active: _cropMenu
            onSelected: {
                _cropType = type
                _cropRatio = ratio
                previewImage.aspectRatio = ratio
                previewImage.aspectRatioType = type
                _cropMenu = false
            }
            onCanceled: _cropMenu = false
        }
    }

    Notification {
        id: errorNotification
        isTransient: true
        urgency: Notification.Critical
        icon: "icon-system-warning"
    }
}
