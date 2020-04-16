/****************************************************************************************
**
** Copyright (C) 2019 Open Mobile Platform LLC
** All rights reserved.
**
** License: Proprietary.
**
****************************************************************************************/

import QtQuick 2.0
import Sailfish.Silica 1.0
import com.jolla.gallery 1.0
import com.jolla.gallery.nextcloud 1.0

MediaSourceIcon {
    id: root

    property bool _showPlaceholder

    // shuffle thumbnails with timer similar to that of gallery photos but without aligning exactly
    timerEnabled: allPhotosModel.count > 1
    timerInterval: Math.floor(Math.random() * 8000) + 6000

    onTimerTriggered: _showNextValidPhoto()

    function _showNextValidPhoto() {
        var startIndex = (slideShow.currentIndex + 1) % allPhotosModel.count
        var restarted = false

        // Loop until a downloaded thumbnail is found.
        for (var i = startIndex; i < allPhotosModel.count; ++i) {
            var data = allPhotosModel.at(i)
            if (data.thumbnailPath.toString().length > 0) {
                slideShow.currentIndex = i
                break
            }
            if (restarted && i === startIndex) {
                // There are no downloaded thumbnails yet
                root._showPlaceholder = true
                break
            } else if (i === allPhotosModel.count - 1) {
                restarted = true
                i = -1
            }
        }
    }

    ListView {
        id: slideShow

        anchors.fill: parent
        interactive: false
        currentIndex: -1
        clip: true
        orientation: ListView.Horizontal
        cacheBuffer: width * 2
        highlightMoveDuration: 0    // jump immediately to initial image instead of animating

        model: allPhotosModel

        delegate: Image {
            id: thumbnail

            source: model.thumbnailPath
            width: slideShow.width
            height: slideShow.height
            sourceSize.width: slideShow.width
            sourceSize.height: slideShow.height
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
        }
    }

    NextcloudPhotoModel {
        id: allPhotosModel

        imageCache: NextcloudImageCache

        onCountChanged: {
            if (slideShow.currentIndex < 0) {
                _showNextValidPhoto()
                slideShow.highlightMoveDuration = -1    // restore animation for cycling to next image
            }
        }
    }

    NextcloudUserModel {
        id: nextcloudUsers

        imageCache: NextcloudImageCache
    }

    Image {
        anchors.fill: parent
        source: "image://theme/graphic-service-nextcloud"
        fillMode: Image.PreserveAspectCrop
        clip: true
        visible: _showPlaceholder
                 || (slideShow.currentItem
                     && (slideShow.currentItem.status === Image.Null || slideShow.currentItem.status === Image.Error))
    }
}
