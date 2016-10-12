import QtQuick 2.0
import Sailfish.Silica 1.0

MediaContainerListDelegate {
    id: root

    property alias color: playlistRectangle.color
    property int songCount

    contentHeight: playlistRectangle.height + 2*Theme.paddingSmall
    leftPadding: Theme.itemSizeExtraLarge + Theme.paddingLarge

    //: This is for the playlists page. Shows the number of songs in a playlist.
    //% "%n songs"
    subtitle: qsTrId("mediaplayer-le-number-of-songs", songCount)

    Rectangle {
        id: playlistRectangle

        width: Theme.iconSizeMedium
        height: Theme.iconSizeMedium
        y: Theme.paddingSmall
        x: Theme.itemSizeExtraLarge - Theme.paddingSmall - width
        radius: Theme.paddingSmall / 2
        opacity: root.highlighted ? 1.0 : 0.7

        Image {
            source: "image://theme/graphic-media-playlist-medium"
            anchors.centerIn: parent
        }
    }
}
