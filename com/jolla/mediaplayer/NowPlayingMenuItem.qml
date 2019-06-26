// -*- qml -*-

import QtQuick 2.0
import Sailfish.Silica 1.0
import com.jolla.mediaplayer 1.0

MenuItem {
    visible: visualAudioAppModel.active
    
    //% "Play queue"
    text: qsTrId("mediaplayer-he-play-queue")

    // Avoid font fitting that menu item does by default for too long labels
    fontSizeMode: Text.FixedSize

    onClicked: pageStack.animatorPush(Qt.resolvedUrl("PlayQueuePage.qml"))
}
