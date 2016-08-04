// -*- qml -*-

import QtQuick 2.0
import Sailfish.Silica 1.0
import com.jolla.mediaplayer 1.0

Dialog {
    id: dialog

    property variant media
    property Item pageToPop
    property bool hasTitle: playlistName.text.trim().length > 0

    canNavigateForward: hasTitle

    onAccepted: {
        if (playlists.createPlaylist(playlistName.text, dialog.media)) {
            // TODO: Should we provide feedback?
            if (pageToPop) {
                pageStack.pop(pageToPop)
            }
        }
        // TODO: should we dismiss the previous page too?
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height
        Column {
            id: column

            width: parent.width
            spacing: Theme.paddingLarge

            DialogHeader { }

            TextField {
                id: playlistName
                width: parent.width
                focus: true
                focusOutBehavior: FocusBehavior.KeepFocus

                //: placeholder for the text field in add playlist dialog.
                //% "Playlist name"
                placeholderText: qsTrId("mediaplayer-ph-playlist-name")
                EnterKey.enabled: dialog.hasTitle
                EnterKey.highlighted: dialog.hasTitle
                EnterKey.iconSource: "image://theme/icon-m-enter-accept"
                EnterKey.onClicked: dialog.accept()
            }
        }
    }
}
