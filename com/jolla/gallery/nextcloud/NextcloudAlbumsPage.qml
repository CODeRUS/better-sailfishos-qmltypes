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
import com.jolla.gallery.nextcloud 1.0

Page {
    id: root

    property alias model: view.model

    SilicaListView {
        id: view

        anchors.fill: parent
        header: PageHeader {
            title: view.model.userDisplayName || view.model.userId
        }
        cacheBuffer: Screen.height

        delegate: NextcloudAlbumDelegate {
            accountId: model.accountId
            userId: model.userId
            albumId: model.albumId
            albumName: model.albumName
            albumThumbnailPath: model.thumbnailPath
            photoCount: model.photoCount

            onClicked: {
                var props = {
                    "accountId": accountId,
                    "userId": userId,
                    "albumId": albumId,
                    "albumName": albumName
                }
                pageStack.animatorPush(Qt.resolvedUrl("NextcloudPhotoGridPage.qml"), props)
            }
        }

        VerticalScrollDecorator {}
    }
}
