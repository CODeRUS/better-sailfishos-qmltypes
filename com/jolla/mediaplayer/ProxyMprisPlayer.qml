import QtQuick 2.0
import org.nemomobile.mpris 1.0

QtObject {
    // Proxy for the Mpris2 Player
    property bool canControl
    property bool canGoNext
    property bool canGoPrevious
    property bool canPause
    property bool canPlay
    property bool canSeek
    property int loopStatus: Mpris.None
    property real maximumRate: 1
    property var metadata
    property real minimumRate: 1
    property int playbackStatus: Mpris.Stopped
    property int position
    property real rate: 1
    property bool shuffle
    property real volume

    function onPauseRequested() {}
    function onPlayRequested() {}
    function onPlayPauseRequested() {}
    function onStopRequested() {}
    function onNextRequested() {}
    function onPreviousRequested() {}
    function onSeekRequested(offset) {}
    function onSetPositionRequested(trackId, position) {}
    function onOpenUriRequested(url) {}
    function onLoopStatusRequested(loopStatus) {}
    function onShuffleRequested(shuffle) {}
}
