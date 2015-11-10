/*
 * Copyright (C) 2012-2015 Jolla Ltd.
 *
 * The code in this file is distributed under multiple licenses, and as such,
 * may be used under any one of the following licenses:
 *
 *   - GNU General Public License as published by the Free Software Foundation;
 *     either version 2 of the License (see LICENSE.GPLv2 in the root directory
 *     for full terms), or (at your option) any later version.
 *   - GNU Lesser General Public License as published by the Free Software
 *     Foundation; either version 2.1 of the License (see LICENSE.LGPLv21 in the
 *     root directory for full terms), or (at your option) any later version.
 *   - Alternatively, if you have a commercial license agreement with Jolla Ltd,
 *     you may use the code under the terms of that license instead.
 *
 * You can visit <https://sailfishos.org/legal/> for more information
 */

// -*- qml -*-

import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Silica.theme 1.0
import com.jolla.mediaplayer 1.0

DockedPanel {
    id: panel

    property alias author: slider.author
    property alias title: slider.title
    property alias duration: slider.duration
    property alias position: slider.position
    property alias state: playPause.playbackState
    property alias showAddToPlaylistButton: row.showAddToPlaylistButton
    property alias repeat: repeatSwitch.repeatProxy
    property alias shuffle: shuffleSwitch.shuffleProxy

    property bool active: false
    property bool playing: false

    property bool _isLandscape: pageStack && pageStack.currentPage && pageStack.currentPage.isLandscape

    width: parent.width
    height: column.height + (_isLandscape ? Theme.paddingLarge : Theme.paddingLarge * 2)
    contentHeight: height
    flickableDirection: Flickable.VerticalFlick
    visible: root.applicationActive

    opacity: Qt.inputMethod.visible ? 0.0 : 1.0
    Behavior on opacity { FadeAnimation {}}

    function showControls() {
        if (playing) {
            open = true
        }
    }

    function hideControls() {
        open = false
    }

    onOpenChanged: if (!open) AudioPlayer.pause()
    onActiveChanged: if (!active) hideControls()

    Column {
        id: column

        width: parent.width
        y: panel._isLandscape ? Theme.paddingSmall : Theme.paddingMedium
        spacing: panel._isLandscape ? Theme.paddingSmall : Theme.paddingLarge

        Slider {
            id: slider

            property string author
            property string title
            property int duration
            property int position

            width: parent.width
            handleVisible: false
            valueText: Format.formatDuration(slider.value, slider.value >= 3600
                                             ? Format.DurationLong
                                             : Format.DurationShort)

            label: {
                if (author.length > 0) {
                    if (title.length > 0) {
                        return "%0 - %1".arg(author).arg(title)
                    } else {
                        return author
                    }
                } else if (title.length > 0) {
                    return title
                }
                return ""
            }

            minimumValue: 0
            maximumValue: duration > 0 ? duration : 1
            onReleased: AudioPlayer.setPosition(value * 1000)
            onPositionChanged: if (!pressed) value = position
        }
        Row {
            id: navigation
            width: parent.width

            IconButton {
                id: gotoPrevious
                width: parent.width / 3
                icon.source: "image://theme/icon-m-previous"
                anchors.verticalCenter: parent.verticalCenter
                onClicked: AudioPlayer.playPrevious(true)
            }

            IconButton {
                id: playPause

                property int playbackState: Audio.Stopped

                width: parent.width / 3
                icon.source: playbackState == Audio.Playing ? "image://theme/icon-m-pause?" + Theme.highlightColor : "image://theme/icon-m-play"
                onClicked: AudioPlayer.playPause()
            }

            IconButton {
                id: gotoNext
                width: parent.width / 3
                icon.source: "image://theme/icon-m-next"
                anchors.verticalCenter: parent.verticalCenter
                onClicked: AudioPlayer.playNext(true)
            }
        }
    }

    PushUpMenu {
        id: bottomMenu

        bottomMargin: panel._isLandscape ? Theme.itemSizeExtraSmall : Theme.itemSizeSmall

        Row {
            id: row
            width: parent.width

            property bool showAddToPlaylistButton: true
            property real childWidth: width / (showAddToPlaylistButton ? 3 : 2)

            Behavior on childWidth {
                NumberAnimation { duration: 250 }
            }

            IconButton {
                id: addToPlaylistButton
                width: row.childWidth
                anchors.bottom: parent.bottom
                anchors.bottomMargin: -Theme.paddingSmall
                icon.source: "image://theme/icon-m-add"
                opacity: showAddToPlaylistButton ? 1.0 : 0
                visible: opacity != 0

                Behavior on opacity { FadeAnimation {} }

                onClicked: {
                    bottomMenu.hide()
                    pageStack.push(Qt.resolvedUrl("AddToPlaylistPage.qml"), {media: AudioPlayer.currentItem})
                }
            }

            /*
            TODO: Implement sharing
            IconButton {
                width: row.childWidth
                anchors.bottom: parent.bottom
                icon.source: "image://theme/icon-m-share"
            }
            */

            Switch {
                id: shuffleSwitch

                property bool shuffleProxy

                width: row.childWidth
                anchors.bottom: parent.bottom
                icon.source: "image://theme/icon-m-shuffle"
                onCheckedChanged: AudioPlayer.shuffle = checked
                onShuffleProxyChanged: if (checked != shuffleProxy) checked = shuffleProxy
            }

            Switch {
                id: repeatSwitch

                property bool repeatProxy

                width: row.childWidth
                anchors.bottom: parent.bottom
                icon.source: "image://theme/icon-m-repeat"
                onCheckedChanged: AudioPlayer.repeat = checked
                onRepeatProxyChanged: if (checked != repeatProxy) checked = repeatProxy
            }
        }
    }

    Connections {
        target: AudioPlayer
        onTryingToPlay: showControls()
    }
}
