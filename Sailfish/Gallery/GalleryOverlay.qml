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
        height: toolbar.height + 2* toolbar.anchors.bottomMargin
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

    Slider {
        id: positionSlider

        visible: !isImage
        opacity: overlay.error ? 0.0 : 1.0
        anchors { left: parent.left; right: toolbar.left; bottom: parent.bottom }
        rightMargin: Theme.paddingLarge

        height: Math.max(implicitHeight, toolbar.height + toolbar.anchors.bottomMargin * 2 + _valueLabel.height/2)
        handleVisible: false
        minimumValue: 0
        maximumValue: overlay._duration > 0 ? overlay._duration : 1

        valueText: Format.formatDuration(value, value >= 3600
                                         ? Format.DurationLong
                                         : Format.DurationShort)

        onReleased: {
            var position = value * 1000
            if (!player) createPlayer()
            if (!player.loaded) {
                player.pause() // force load
            }
            player.seek(position)
        }

        Connections {
            target: player
            onPositionChanged: {
                if (!positionSlider.pressed) {
                    positionSlider.value = player.position / 1000
                }
            }
        }
        Connections {
            target: player
            onSourceChanged: positionSlider.value = 0
        }
    }

    Row {
        id: toolbar

        x: isImage ? parent.width/2 - width/2 : parent.width - width - Theme.horizontalPageMargin
        anchors  {
            bottom: parent.bottom
            bottomMargin: Theme.paddingLarge
        }
        spacing: Theme.paddingLarge

        Loader {
            id: additionalActionsLoader
            anchors.verticalCenter: parent.verticalCenter
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

    FileInfo {
        id: fileInfo
        source: overlay.source
    }

    Component {
        id: remorsePopupComponent
        RemorsePopup {}
    }
}
