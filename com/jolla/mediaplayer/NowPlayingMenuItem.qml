// -*- qml -*-

import QtQuick 2.0
import Sailfish.Silica 1.0
import com.jolla.mediaplayer 1.0

MenuItem {
    visible: visualAudioAppModel.active
    text: nowPlayingText(visualAudioAppModel.metadata)

    // Avoid font fitting that menu item does by default for too long labels
    fontSizeMode: Text.FixedSize

    onClicked: pageStack.push(Qt.resolvedUrl("PlayQueuePage.qml"))

    function nowPlayingText(metadata) {
        if (!metadata) {
            return ""
        }

        if (metadata.title !== "" && metadata.artist !== "") {
            return metadata.artist + " - " + metadata.title
        } else if (metadata.artist !== "") {
            return metadata.artist
        } else {
            return metadata.title
        }
    }
}
