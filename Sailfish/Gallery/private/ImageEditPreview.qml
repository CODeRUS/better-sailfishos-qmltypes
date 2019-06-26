/****************************************************************************
**
** Copyright (C) 2013 Jolla Ltd.
** Contact: Raine Mäkeläinen <raine.makelainen@jollamobile.com>
**
****************************************************************************/

import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Gallery 1.0
import Sailfish.Gallery.private 1.0

Item {
    id: root

    // Uncomment to debug
    // FlickableDebugItem { Component.onCompleted: titleLabel.text = "" }

    property bool cropOnly

    // Aspect ratio as width / height
    property real aspectRatio: -1.0
    property string aspectRatioType: "none"

    property bool isPortrait: width < height
    property bool active
    property bool editInProgress
    property alias source: zoomableImage.source
    property alias target: editor.target
    property int previewRotation: zoomableImage.imageRotation
    property alias previewBrightness: zoomableImage.brightness
    property alias previewContrast: zoomableImage.contrast
    property alias animatingBrightnessContrast: zoomableImage.animatingBrightnessContrast
    readonly property alias longPressed: zoomableImage.longPressed

    signal edited
    signal failed

    clip: true

    function transposedSize(item) {
        var transpose = (previewRotation % 180) != 0

        var width = transpose ? item.height : item.width
        var height = transpose ? item.width : item.height
        return Qt.size(width, height)
    }

    function rotatePoint(x, y, cropSize, imageSize, rotation) {
        var transpose = (rotation % 180) != 0
        var invert = (rotation < 0 ? rotation + 360 : rotation) >= 180
        var _x, _y
        if (transpose) {
            _x = invert ? imageSize.width - cropSize.width - y : y
            _y = invert ? x : imageSize.height - cropSize.height - x
        } else {
            _x = invert ? imageSize.width - cropSize.width - x : x
            _y = invert ? imageSize.height - cropSize.height - y : y
        }

        return Qt.point(_x, _y)
    }

    function crop() {
        editInProgress = true
        var cropSize = transposedSize(editor)

        var transpose = (zoomableImage.baseRotation % 180) != 0
        var imageWidth = transpose ? zoomableImage.photo.height : zoomableImage.photo.width
        var imageHeight = transpose ? zoomableImage.photo.width : zoomableImage.photo.height
        var imageSize = Qt.size(imageWidth, imageHeight)
        var position = rotatePoint(zoomableImage.contentX + zoomableImage.leftMargin,
                                   zoomableImage.contentY + zoomableImage.topMargin,
                                   cropSize,
                                   imageSize,
                                   previewRotation % 360)

        editor.crop(cropSize, imageSize, position)
    }

    function rotateImage() {
        editInProgress = true
        editor.rotate(metadata.orientation + zoomableImage.imageRotation)
    }

    function adjustLevels() {
        editInProgress = true
        editor.adjustLevels(root.previewBrightness, root.previewContrast)
    }

    function resetScale() {
        editor.setSize()
        zoomableImage.resetScale()
    }

    function previewRotate(angle) {
        zoomableImage.rotate(angle)
        editor.setSize()
    }

    onAspectRatioTypeChanged: resetScale()

    onIsPortraitChanged: {
        // Reset back to original aspect ratio that needs to be calculated
        if (aspectRatioType == "original") {
            aspectRatio = -1.0
        }

        delayedReset.restart()
    }

    // ImageMetadata is needed to track the real orientation
    // when the file is being edited.
    ImageMetadata {
        id: metadata
        source: root.source
    }

    ZoomableImage {
        id: zoomableImage

        anchors.fill: parent
        baseRotation: -metadata.orientation
        photo.onStatusChanged: if (status === Image.Ready) delayedReset.restart()
    }

    Timer {
        id: delayedReset
        running: true; interval: 10
        onTriggered: root.resetScale()
    }

    Label {
        visible: zoomableImage.error
        //: Image to be edited can't be opened
        //% "Oops, image error!"
        text: qsTrId("sailfish-components-gallery-la_image-loading-error")
        anchors.centerIn: zoomableImage
        width: parent.width - 2 * Theme.paddingMedium
        wrapMode: Text.Wrap
        font.pixelSize: Theme.fontSizeLarge
        horizontalAlignment: Text.AlignHCenter
    }

    ImageEditor {
        id : editor

        anchors.centerIn: parent
        source: zoomableImage.source

        function reset() {
            zoomableImage.leftMargin = 0
            zoomableImage.rightMargin = 0
            zoomableImage.topMargin = 0
            zoomableImage.bottomMargin = 0
            zoomableImage.minimumScale = -1
            zoomableImage.fittedScale = -1
            zoomableImage.resetScale()
        }

        // As a function to avoid binding loops
        function setSize() {
            if (root.width === 0 || root.height == 0 ) return

            reset()
            var realAspectRatio = !zoomableImage.transpose
                    ? metadata.width / metadata.height
                    : metadata.height / metadata.width

            if (aspectRatio === -1.0) {
                return
            } else if (aspectRatio === 0.0) {
                aspectRatio = realAspectRatio
            }

            if (isPortrait) {
                var maxWidth = root.width - Theme.itemSizeMedium
                var tmpHeight = maxWidth / aspectRatio
                var maxHeight = root.height - header.height
                if (tmpHeight > maxHeight) {
                    maxWidth = maxHeight * aspectRatio
                }

                width = maxWidth
                height = Math.round(width / aspectRatio)
            } else {
                maxHeight = root.height - Theme.itemSizeSmall
                var tmpWidth = aspectRatio * maxHeight
                maxWidth = root.width - Theme.itemSizeMedium
                if (tmpWidth > maxWidth) {
                    maxHeight = maxWidth / aspectRatio
                }
                height = maxHeight
                width =  Math.round(aspectRatio * height)
            }

            zoomableImage.leftMargin = Qt.binding( function () {
                var photoSize = zoomableImage.transpose ? zoomableImage.photo.height : zoomableImage.photo.width
                return Math.max(0, (Math.min(photoSize, root.width) - editor.width)/2)
            })
            zoomableImage.rightMargin = Qt.binding( function () { return zoomableImage.leftMargin } )
            zoomableImage.topMargin = Qt.binding( function () {
                var photoSize = zoomableImage.transpose ? zoomableImage.photo.width : zoomableImage.photo.height
                return Math.max(0, (Math.min(photoSize, root.height) - editor.height)/2)
            })
            zoomableImage.bottomMargin = Qt.binding( function () { return zoomableImage.topMargin })

            var contentHeight = Math.min(zoomableImage.transpose ? zoomableImage.photo.width : zoomableImage.photo.height, root.height)
            var contentWidth = Math.min(zoomableImage.transpose ? zoomableImage.photo.height : zoomableImage.photo.width, root.width)

            zoomableImage.minimumScale = zoomableImage._scale * Math.max(height/contentHeight, width/contentWidth)
            if (realAspectRatio !== aspectRatio) {
                zoomableImage.fittedScale = zoomableImage.minimumScale
            }

            zoomableImage.resetScale()
        }

        onCropped: {
            editInProgress = false
            if (success) {
                root.source = target
                root.edited()
            } else {
                root.failed()
            }
        }

        onRotated: {
            editInProgress = false
            root.previewRotation = 0
            if (success) {
                root.source = target
                root.edited()
            } else {
                console.log("Failed to rotate image!")
                root.failed()
            }
        }

        onLevelsAdjusted: {
            editInProgress = false
            root.previewBrightness = 0.0
            root.previewContrast = 0.0
            if (success) {
                root.source = target
                root.edited()
            } else {
                console.log("Failed to adjust image levels!")
                root.failed()
            }
        }
    }

    DimmedRegion {
        anchors.fill: parent
        color: Theme.highlightDimmerFromColor(Theme.highlightDimmerColor, Theme.LightOnDark)
        opacity: aspectRatioType !== "none" ? 0.5 : 0.0
        visible: !longPressed


        target: root
        area: Qt.rect(0, 0, root.width, root.height)
        exclude: [ editor ]
        z: 1

        Behavior on opacity { FadeAnimator {} }
    }

    BusyIndicator {
        anchors.centerIn: parent
        size: BusyIndicatorSize.Large
        running: editInProgress || zoomableImage.error
    }
}
