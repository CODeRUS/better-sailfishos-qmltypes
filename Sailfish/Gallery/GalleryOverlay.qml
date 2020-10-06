import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Silica.private 1.0
import Sailfish.Gallery 1.0
import Sailfish.Ambience 1.0

Item {
    id: overlay

    property QtObject player
    property bool active: true
    property bool viewerOnlyMode

    property alias toolbar: toolbar
    property alias additionalActions: additionalActionsLoader.sourceComponent
    property alias detailsButton: detailsButton
    property alias localFile: fileInfo.localFile
    property alias editingAllowed: editButton.visible
    property alias deletingAllowed: deleteButton.visible
    property alias sharingAllowed: shareButton.visible
    property alias ambienceAllowed: ambienceButton.visible
    readonly property bool allowed: isImage || localFile
    readonly property bool playing: player && player.playing
    property alias topFade: topFade
    property alias fadeOpacity: topFade.fadeOpacity

    property url source
    property string itemId
    property bool isImage
    property bool error
    property int duration: 1
    readonly property int _duration: {
        if (player && player.loaded) {
            return player.duration / 1000
        } else {
            return duration
        }
    }
    property Item _remorsePopup
    property Component additionalShareComponent

    function remorseAction(text, action) {
        if (!_remorsePopup) {
            _remorsePopup = remorsePopupComponent.createObject(overlay)
        }
        if (!_remorsePopup.active) {
            _remorsePopup.execute(text, action)
        }
    }

    function seekForward() {
        seek(10000, true /*relative*/)
    }

    function seekBackward() {
        seek(-10000, true /*relative*/)
    }

    Connections {
        id: delayedRelativeSeek

        property bool pending
        property int position
        target: player
        onLoadedChanged: {
            if (pending) {
                overlay.seek(position, true /* relative */)
                pending = false
            }
        }
    }

    function seek(position, relative) {
        // don't hide controls just yet if user is seeking
        if (hideOverlayTimer.running) {
            hideOverlayTimer.restart()
        }

        if (!player) createPlayer()
        var loaded = player.loaded
        if (!loaded) {
            player.pause() // force load
        }

        player.busy = true

        if (relative) {
            if (!loaded) {
                // cannot jump 10s before knowing the duration of the clip
                delayedRelativeSeek.pending = true
                delayedRelativeSeek.position = position
            } else {
                seekTimer.position = Math.max(Math.min(player.position + position, _duration * 1000), 0)
            }
        } else {
            seekTimer.position = position
        }
        seekTimer.restart()
    }

    Timer {
        id: seekTimer
        interval: 16
        property int position
        onTriggered: player.seek(position)
    }

    signal createPlayer
    signal remove
    signal edited(string image)

    onSourceChanged: if (_remorsePopup && _remorsePopup.active) _remorsePopup.trigger()

    enabled: active && allowed && source != "" && !(_remorsePopup && _remorsePopup.active)
    Behavior on opacity { FadeAnimator {}}
    opacity: enabled ? 1.0 : 0.0

    FadeGradient {
        id: topFade

        width: parent.width
        height: detailsButton.height + 2 * detailsButton.y
        topDown: true
    }

    FadeGradient {
        id: bottomFade

        fadeOpacity: topFade.fadeOpacity
        width: parent.width
        height: toolbar.height + 2 * toolbarParent.anchors.bottomMargin
        anchors.bottom: parent.bottom
    }

    IconButton {
        id: detailsButton
        x: Theme.horizontalPageMargin
        y: Theme.paddingLarge
        icon.source: "image://theme/icon-m-about"
        visible: localFile && !viewerOnlyMode && itemId.length > 0
        onClicked: if (itemId.length > 0) pageStack.animatorPush("DetailsPage.qml", { modelItem: overlay.itemId } )
    }

    Timer {
        id: hideOverlayTimer
        interval: 4000
        running: overlay.active && playing
        onTriggered: {
            if (positionSlider.pressed) {
                restart()
            } else {
                overlay.active = false
            }
        }
    }


    Column {
        id: toolbarParent
        width: parent.width
        anchors  {
            bottom: parent.bottom
            bottomMargin: parent.height/20
        }
        height: (isImage ? 0 : sliderRow.height) + (toolbar.expanded ? toolbar.height : 0)
        Behavior on height { NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }}

        Row {
            id: sliderRow
            visible: !isImage
            width: parent.width
            Slider {
                id: positionSlider

                enabled: !overlay.error
                opacity: overlay.error ? 0.0 : 1.0
                rightMargin: Theme.paddingLarge
                width: parent.width - downIcon.width - Theme.horizontalPageMargin

                handleVisible: false
                minimumValue: 0
                maximumValue: overlay._duration > 0 ? overlay._duration : 1

                valueText: Format.formatDuration(value, value >= 3600
                                                 ? Format.DurationLong
                                                 : Format.DurationShort)

                onReleased: seek(value * 1000)

                Connections {
                    target: player
                    onPositionChanged: {
                        if (!positionSlider.pressed) {
                            positionSlider.value = player.position / 1000
                        }
                    }
                    onSourceChanged: positionSlider.value = 0
                }

                Timer {
                    interval: 500
                    repeat: true
                    running: player && player.busy && Qt.application.active
                    onRunningChanged: positionSlider.progressOpacity = 1.0
                    onTriggered: positionSlider.progressOpacity = positionSlider.progressOpacity >= 0.99 ? Theme.highlightBackgroundOpacity : 1.0
                }

                property real progressOpacity: 1.0
                Behavior on progressOpacity {
                    NumberAnimation { duration: 400; easing.type: Easing.InOutQuad }
                }

                Binding {
                    target: positionSlider._progressBarItem
                    property: "opacity"
                    value: positionSlider.progressOpacity
                }

            }

            IconButton {
                id: downIcon
                onClicked: toolbar.expanded = !toolbar.expanded
                icon.source: "image://theme/icon-m-change-type"
                icon.rotation: toolbar.expanded ? 0 : 180
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: positionSlider._valueLabel.height/4
            }
        }

        Row {
            id: toolbar

            property int expanded: isImage
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: Theme.paddingLarge
            opacity: expanded ? 1.0 : 0.0
            Behavior on opacity { FadeAnimator {}}
            enabled: expanded

            Loader {
                id: additionalActionsLoader
                anchors.verticalCenter: parent.verticalCenter
            }

            IconButton {
                visible: !isImage
                icon.source: "image://theme/icon-m-page-up"
                icon.rotation: -90
                anchors.verticalCenter: parent.verticalCenter
                enabled: !overlay.error && (player && player.position !== 0)
                opacity: overlay.error ? 0.0 : 1.0

                onClicked: seekBackward()

                width: Theme.itemSizeSmall + rewindLabel.width
                icon.anchors.horizontalCenterOffset: rewindLabel.width/2 + rewindLabel.x/2
                Label {
                    id: rewindLabel
                    text: "-10s"
                    opacity: parent.enabled ? 1.0 : Theme.opacityLow
                    font.pixelSize: Theme.fontSizeSmall
                    x: Theme.paddingMedium
                    anchors {
                        verticalCenter: parent.verticalCenter
                        verticalCenterOffset: -Math.round(Theme.paddingSmall/2)
                    }
                }
            }

            IconButton {
                visible: !isImage
                icon.source: "image://theme/icon-m-page-up"
                icon.rotation: 90
                anchors.verticalCenter: parent.verticalCenter
                enabled: !overlay.error && (!player || player.position !== player.duration)
                opacity: overlay.error ? 0.0 : 1.0

                onClicked: seekForward()
                width: Theme.itemSizeSmall + forwardLabel.width
                icon.anchors.horizontalCenterOffset: -forwardLabel.width/2 - forwardLabel.anchors.rightMargin/2
                Label {
                    id: forwardLabel
                    text: "+10s"
                    opacity: parent.enabled ? 1.0 : Theme.opacityLow
                    font.pixelSize: Theme.fontSizeSmall
                    anchors {
                        verticalCenter: parent.verticalCenter
                        verticalCenterOffset: -Math.round(Theme.paddingSmall/2)
                        right: parent.right
                        rightMargin: Theme.paddingMedium
                    }
                }
            }

            IconButton {
                id: deleteButton
                icon.source: "image://theme/icon-m-delete"
                visible: localFile
                anchors.verticalCenter: parent.verticalCenter
                onClicked: overlay.remove()
            }

            IconButton {
                id: editButton
                icon.source: "image://theme/icon-m-edit"
                visible: fileInfo.editableImage && isImage && !viewerOnlyMode
                anchors.verticalCenter: parent.verticalCenter
                onClicked: {
                    editPageLoader.active = true
                    pageStack.animatorPush(editPageLoader.item)
                }

                Loader {
                    id: editPageLoader
                    active: false
                    sourceComponent: ImageEditDialog {
                        source: overlay.source
                        onEdited: overlay.edited(target)
                        onFinished: editPageLoader.active = false

                        Rectangle {
                            z: 1000
                            color: "black"
                            anchors.fill: parent
                            enabled: editInProgress || editSuccessful
                            opacity: enabled ? 1.0 : 0.0
                            parent: overlay
                            BusyIndicator {
                                size: BusyIndicatorSize.Large
                                anchors.centerIn: parent
                                running: editInProgress
                            }
                            TouchBlocker {
                                anchors.fill: parent
                            }
                        }
                    }
                }
            }

            IconButton {
                id: shareButton
                icon.source: "image://theme/icon-m-share"
                anchors.verticalCenter: parent.verticalCenter
                onClicked: {
                    if (player && player.playing) {
                        player.pause()
                    }

                    pageStack.animatorPush("Sailfish.TransferEngine.SharePage",
                                           {
                                               "source": overlay.source,
                                               "mimeType": localFile ? fileInfo.mimeType
                                                                     : "text/x-url",
                                                                       "content": localFile ? undefined
                                                                                            : { "type": "text/x-url", "status": overlay.source },
                                               "serviceFilter": ["sharing", "e-mail"],
                                               "additionalShareComponent": additionalShareComponent
                                           })
                }
            }

            IconButton {
                id: ambienceButton

                property bool suppressClick

                visible: isImage
                icon.source: "image://theme/icon-m-ambience"
                anchors.verticalCenter: parent.verticalCenter
                onClicked: {
                    if (suppressClick) return
                    suppressClick = true
                    Ambience.create(overlay.source, function(ambienceId) {
                        pageStack.animatorPush("com.jolla.gallery.ambience.AmbienceSettingsDialog", { contentId: ambienceId })
                        ambienceButton.suppressClick = false
                    })
                }
            }
        }
    }

    FileInfo {
        id: fileInfo
        source: overlay.source
    }

    Component {
        id: remorsePopupComponent
        RemorsePopup {}
    }
}
