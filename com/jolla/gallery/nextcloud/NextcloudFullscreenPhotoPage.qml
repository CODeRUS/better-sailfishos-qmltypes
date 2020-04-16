/****************************************************************************************
**
** Copyright (C) 2019 Open Mobile Platform LLC
** All rights reserved.
**
** License: Proprietary.
**
****************************************************************************************/

import QtQuick 2.6
import Sailfish.Silica 1.0
import Sailfish.Silica.private 1.0 as SilicaPrivate
import Sailfish.Gallery 1.0
import com.jolla.gallery 1.0
import com.jolla.gallery.nextcloud 1.0

FullscreenContentPage {
    id: root

    property var imageModel
    property alias currentIndex: slideshowView.currentIndex

    allowedOrientations: Orientation.All

    // Update the Cover via window.activeObject property
    Binding {
        target: window
        property: "activeObject"
        property bool active: root.status === PageStatus.Active
        value: { "url": active ? slideshowView.currentItem.source : "", "mimeType": active ? slideshowView.currentItem.mimeType : "" }
    }

    SlideshowView {
        id: slideshowView

        anchors.fill: parent
        itemWidth: width
        itemHeight: height

        model: root.imageModel

        delegate: ImageViewer {
            id: delegateItem

            readonly property string mimeType: model.fileType
            readonly property bool downloading: imageDownloader.status === NextcloudImageDownloader.Downloading

            width: slideshowView.width
            height: slideshowView.height

            source: imageDownloader.status === NextcloudImageDownloader.Ready
                     ? imageDownloader.imagePath
                     : ""
            active: PathView.isCurrentItem
            viewMoving: slideshowView.moving

            onZoomedChanged: overlay.active = !zoomed
            onClicked: {
                if (zoomed) {
                    zoomOut()
                } else {
                    overlay.active = !overlay.active
                }
            }

            InfoLabel {
                //% "Image download failed"
                text: qsTrId("jolla_gallery_nextcloud-la-image_download_failed")
                anchors.centerIn: parent
                visible: imageDownloader.status === NextcloudImageDownloader.Error
            }

            NextcloudImageDownloader {
                id: imageDownloader

                accountId: model.accountId
                userId: model.userId
                albumId: model.albumId
                photoId: model.photoId

                imageCache: NextcloudImageCache
                downloadImage: delegateItem.active
            }
        }
    }

    GalleryOverlay {
        id: overlay

        anchors.fill: parent

        // Currently, images are only downloaded and never uploaded, so
        // don't allow editing or deleting.
        deletingAllowed: false
        editingAllowed: false

        source: slideshowView.currentItem ? slideshowView.currentItem.source : ""
        isImage: true
        duration: 1
        error: slideshowView.currentItem && slideshowView.currentItem.error
    }

    IconButton {
        id: detailsButton
        x: Theme.horizontalPageMargin
        y: Theme.paddingLarge
        icon.source: "image://theme/icon-m-about"
        onClicked: {
            var props = {
                "modelData": imageModel.at(root.currentIndex),
                "imageMetaData": slideshowView.currentItem.imageMetaData
            }
            pageStack.animatorPush("NextcloudImageDetailsPage.qml", props)
        }
    }

    SilicaPrivate.DismissButton {}

    BusyIndicator {
        anchors.centerIn: parent
        size: BusyIndicatorSize.Large
        running: slideshowView.currentItem && slideshowView.currentItem.downloading
    }
}
