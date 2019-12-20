import QtQuick 2.0
import Sailfish.Silica 1.0

MediaContainerListDelegate {
    id: root

    property color color: Theme.primaryColor
    property color highlightColor: Theme.highlightColor
    property int songCount

    leftPadding: Theme.itemSizeExtraLarge + Theme.paddingLarge

    //: This is for the playlists page. Shows the number of songs in a playlist.
    //% "%n songs"
    subtitle: qsTrId("mediaplayer-le-number-of-songs", songCount)

    Rectangle {
        id: playlistRectangle

        width: Theme.iconSizeMedium
        height: Theme.iconSizeMedium
        anchors.verticalCenter: parent.verticalCenter
        x: Theme.itemSizeExtraLarge - Theme.paddingSmall - width
        radius: Theme.paddingSmall / 2
        color: root.highlighted ? root.highlightColor : root.color

        Image {
            source: "image://theme/graphic-media-playlist-medium"
            anchors.centerIn: parent
        }
    }
}
