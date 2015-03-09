import QtQuick 2.0
import Sailfish.Ambience 1.0
import org.nemomobile.thumbnailer 1.0
import com.jolla.gallery 1.0

MediaSourceIcon {
    id: root

    property int galleryCount: model ? model.count : 0
    onTimerTriggered: slideShow.currentIndex = (slideShow.currentIndex + 1) % galleryCount
    timerEnabled: galleryCount > 1

    ListView {
        id: slideShow
        interactive: false
        currentIndex: 0
        clip: true
        orientation: ListView.Horizontal
        cacheBuffer: width * 2 // Make sure non-visible thumbs are downloaded
        anchors.fill: parent

        model: root.model

        delegate: Thumbnail {
            source: wallpaperUrl
            sourceSize.width: slideShow.width
            sourceSize.height: slideShow.width
        }
    }

}
