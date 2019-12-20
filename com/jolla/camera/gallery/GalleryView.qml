import QtQuick 2.1
import QtQml.Models 2.1
import Sailfish.Silica 1.0
import Sailfish.Silica.private 1.0 as Private
import Sailfish.Gallery 1.0
import QtMultimedia 5.0
import com.jolla.camera 1.0
import org.nemomobile.policy 1.0
import ".."

ListView {
    id: root

    property alias overlay: overlay
    readonly property bool positionLocked: !overlay.active && playing

    readonly property bool active: page.galleryActive
    property QtObject captureModel

    property CameraPage page

    readonly property url source: currentItem ? currentItem.source : ""
    readonly property QtObject player: playerLoader.item ? playerLoader.item.player : null
    readonly property bool playing: player && player.playing
    property int _preOrientationChangeIndex

    function _positionViewAtBeginning() {
        currentIndex = count - 1
        positionViewAtEnd()
    }

    model: delegateModel
    boundsBehavior: Flickable.StopAtBounds
    cacheBuffer: width

    snapMode: ListView.SnapOneItem
    highlightRangeMode: ListView.StrictlyEnforceRange
    // Normally transition is handled through a different path when flicking,
    // avoid slow transition if triggered by ListView for some reason
    highlightMoveDuration: 300

    orientation: ListView.Horizontal
    currentIndex: count - 1
    pressDelay: 0

    clip: true
    interactive: count > 1 && !positionLocked
    flickDeceleration: Theme.flickDeceleration
    maximumFlickVelocity: Theme.maximumFlickVelocity

    onCurrentIndexChanged: {
        if (!moving) {
            // ListView's item positioning and currentIndex can get out of sync
            // when items are removed from and possibly when inserted into the
            // model.  Finding and fixing all the corner cases in ListView is a
            // bit of a battle so as a final safeguard, we force the position to
            // update if anything other than flicking the list changes the current
            // index.
            if (page.orientationTransitionRunning && currentIndex != _preOrientationChangeIndex) {
                // Changing the size of the view can cause the currentIndex to change - fix it.
                // The recursion doesn't cause any problems. Hurrah.
                currentIndex = _preOrientationChangeIndex
                return
            }
            positionViewAtIndex(currentIndex, ListView.SnapPosition)
        }
    }
    onActiveChanged: {
        if (!active) {
            // TODO: Don't touch internal property that can change
            if (overlay._remorsePopup && overlay._remorsePopup.active) overlay._remorsePopup.trigger()
            overlay.active = Qt.binding( function () { return captureModel && captureModel.count > 0 })
        }
    }

    property Item previousItem
    onMovingChanged: {
        if (moving) {
            previousItem = currentItem
        } else if (player && previousItem != currentItem) {
            player.reset()
        }
    }

    Connections {
        target: captureModel
        onCountChanged: if (captureModel.count === 0) page.returnToCaptureMode()
    }

    DelegateModel {
        id: delegateModel

        model: captureModel

        delegate: Loader {
            readonly property var itemId: model.itemId
            readonly property int index: model.index
            readonly property string mimeType: model.mimeType
            readonly property url source: model.url
            readonly property bool resolved: model.resolved
            readonly property int duration: model.duration

            readonly property bool isImage: mimeType.indexOf("image/") == 0
            readonly property bool error: item && item.error

            readonly property bool isCurrentItem: ListView.isCurrentItem

            width: root.width
            height: root.height
            sourceComponent: isImage ? imageComponent : videoComponent
            asynchronous: !isCurrentItem

            Component {
                id: imageComponent

                ImageViewer {

                    onZoomedChanged: overlay.active = !zoomed
                    onClicked: {
                        if (zoomed) {
                            zoomOut()
                        } else {
                            overlay.active = !overlay.active
                        }
                    }

                    source: parent.source

                    active: isCurrentItem && root.active
                    contentRotation: -model.orientation
                    viewMoving: root.moving
                }
            }

            Component {
                id: videoComponent

                VideoPoster {
                    onClicked: overlay.active = !overlay.active
                    onTogglePlay: {
                        playerLoader.active = true
                        player.togglePlay()
                    }

                    contentWidth: root.width
                    contentHeight: root.height

                    source: parent.source
                    mimeType: model.mimeType
                    playing: player && player.playing
                    loaded: player && player.loaded
                    overlayMode: overlay.active
                }
            }
        }
    }

    Connections {
        target: page
        onOrientationTransitionRunningChanged: {
            if (page.orientationTransitionRunning) {
                _preOrientationChangeIndex = root.currentIndex
            }
        }
    }

    contentItem.children: [
        Private.FadeBlocker {},
        Loader {
            id: playerLoader

            active: false
            width: root.width
            height: root.height
            sourceComponent: VideoOutput {
                property alias player: mediaPlayer
                visible: player.playbackState !== MediaPlayer.StoppedState
                source: GalleryMediaPlayer {
                    id: mediaPlayer
                    active: currentItem && !currentItem.isImage && Qt.application.active
                    source: active ? currentItem.source : ""
                    onPlayingChanged: {
                        if (playing && overlay.active) {
                            // go fullscreen for playback if triggered via Play icon.
                            overlay.active = false
                        }
                    }
                    onLoadedChanged: if (loaded) playerLoader.anchors.centerIn = currentItem
                    onStatusChanged: {
                        if (status === MediaPlayer.InvalidMedia) {
                            root.currentItem.item.displayError()
                        }
                    }
                }
            }
        }
    ]


    GalleryOverlay {
        id: overlay

        onRemove: {
            var item = currentItem
            //: Delete an image
            //% "Deleting"
            remorseAction( qsTrId("camera-la-deleting"), function() {
                delegateModel.items.remove(item.DelegateModel.itemsIndex, 1)
                delegateModel.model.deleteFile(item.index)
                item.ListView.delayRemove = false
            })
        }
        onCreatePlayer: playerLoader.active = true

        active: captureModel && captureModel.count > 0
        anchors.fill: parent
        player: root.player
        source: root.source
        itemId: currentItem ? currentItem.itemId : ""
        isImage: currentItem ? currentItem.isImage : true
        duration: currentItem ? currentItem.duration : 1
        error: currentItem && currentItem.error
        editingAllowed: false

        Private.DismissButton {
            popPageOnClick: false
            onClicked: page.returnToCaptureMode()
        }
    }
}
