import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    id: root

    property alias interactionItem: photosItem

    signal itemClicked

    anchors.fill: parent

    PageHeader {
        id: galleryPageTitle

        title: "Gallery"
        _titleItem.color: tutorialTheme.highlightColor
    }

    GalleryItem {
        id: photosItem

        anchors.top: galleryPageTitle.bottom

        count: 234
        thumbnail: "photos"

        //% "Photos"
        title: qsTrId("tutorial-la-gallery_photos_album")

        highlightedColor: Theme.rgba(tutorialTheme.highlightColor, 0.3)
        enabled: appInfoLabel.opacity > 0

        onClicked: root.itemClicked()
    }

    Column {
        width: parent.width
        anchors.top: photosItem.bottom

        GalleryItem {
            count: 42
            thumbnail: "videos"

            //% "Videos"
            title: qsTrId("tutorial-la-gallery_videos_album")

            enabled: false
        }

        GalleryItem {
            count: 129
            thumbnail: "facebook"

            //% "Facebook"
            title: qsTrId("tutorial-la-gallerty_facebook_album")

            enabled: false
        }
    }
}

