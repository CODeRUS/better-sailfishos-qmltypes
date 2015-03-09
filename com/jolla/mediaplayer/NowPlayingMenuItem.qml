// -*- qml -*-

import QtQuick 2.0
import Sailfish.Silica 1.0
import com.jolla.mediaplayer 1.0

MenuItem {
    function nowPlayingText(item) {
        if (!item) {
            return ""
        }

        var author = item.author
        var title = item.title

        if (title && author) {
            return author + " - " + title
        } else if (author && !title) {
            return author
        } else {
            return title
        }
    }

    visible: audioPlayer.active
    text: nowPlayingText(audioPlayer.currentItem)

    onClicked: pageStack.push(Qt.resolvedUrl("PlayQueuePage.qml"))
}
