// -*- qml -*-

import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Media 1.0
import com.jolla.mediaplayer 1.0

MediaListItem {
    property var formatFilter

    highlighted: down || menuOpen
    playing: media.url == visualAudioAppModel.metadata.url
    duration: media.duration
    title: Theme.highlightText(media.title, RegExpHelpers.regExpFromSearchString(formatFilter, false), Theme.highlightColor)
    textFormat: Text.StyledText
    subtitleTextFormat: Text.AutoText
    subtitle: media.author
    onPlayingChanged: if (playing) ListView.view.currentIndex = model.index
}
