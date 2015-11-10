import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    id: root

    property alias interactionItem: photosItem

    signal itemClicked

    anchors.fill: parent

    GalleryItemLarge {
        id: photosItem

        y: 2*Theme.paddingLarge

        count: 251
        thumbnail: "photos"

        //% "Photos"
        title: qsTrId("tutorial-la-gallery_photos_album")

        enabled: appInfoLabel.opacity > 0

        onClicked: root.itemClicked()
    }

    Column {
        anchors {
            top: photosItem.bottom
            topMargin: 2*Theme.paddingLarge
            left: parent.left
            right: parent.right
        }

        spacing: 2*Theme.paddingLarge

        GalleryItemLarge {
            id: videosItem

            count: 21
            thumbnail: "videos"

            //% "Videos"
            title: qsTrId("tutorial-la-gallery_videos_album")

            enabled: false
        }

        GalleryItemLarge {
            id: facebookItem

            count: 23
            thumbnail: "facebook"

            //% "Facebook"
            title: qsTrId("tutorial-la-gallerty_facebook_album")

            enabled: false
        }
    }
}
