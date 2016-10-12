import QtQuick 2.0
import org.nemomobile.mpris 1.0

MprisControls {
    property MprisManager mprisManager

    opacity: enabled ? 1.0 : 0.0
    isPlaying: mprisManager.currentService && mprisManager.playbackStatus == Mpris.Playing
    artistAndSongText: {
        var artist = ""
        var song = ""

        if (mprisManager.currentService) {
            var artistTag = Mpris.metadataToString(Mpris.Artist)
            var titleTag = Mpris.metadataToString(Mpris.Title)

            artist = (artistTag in mprisManager.metadata) ? mprisManager.metadata[artistTag].toString() : ""
            song = (titleTag in mprisManager.metadata) ? mprisManager.metadata[titleTag].toString() : ""
        }

        return { "artist": artist, "song": song }
    }
    nextEnabled: mprisManager.currentService && mprisManager.canGoNext
    previousEnabled: mprisManager.currentService && mprisManager.canGoPrevious
    playEnabled: mprisManager.currentService && mprisManager.canPlay
    pauseEnabled: mprisManager.currentService && mprisManager.canPause

    onPlayPauseRequested: {
        if (mprisManager.playbackStatus == Mpris.Playing && mprisManager.canPause) {
            mprisManager.playPause()
        } else if (mprisManager.playbackStatus != Mpris.Playing && mprisManager.canPlay) {
            mprisManager.playPause()
        }
    }
    onNextRequested: if (mprisManager.canGoNext) mprisManager.next()
    onPreviousRequested: if (mprisManager.canGoPrevious) mprisManager.previous()
}
