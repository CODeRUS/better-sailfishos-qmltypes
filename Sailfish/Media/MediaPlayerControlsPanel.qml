import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Media 1.0

DockedPanel {
    id: panel

    property bool active
    property bool playing
    property int repeat: MediaPlayerControls.NoRepeat
    property int shuffle: MediaPlayerControls.NoShuffle
    property bool showAddToPlaylist: true
    property bool showMenu: true

    property alias extraContentItem: extraContent

    property int duration
    property int position
    property int durationScalar: 1
    property alias forwardEnabled: forwardButton.enabled

    property bool _isLandscape: pageStack && pageStack.currentPage && pageStack.currentPage.isLandscape

    signal previousClicked()
    signal playPauseClicked()
    signal nextClicked()

    signal repeatClicked()
    signal shuffleClicked()
    signal addToPlaylist()

    signal sliderReleased(int value)

    function showControls() {
        if (playing) {
            open = true
        }
    }

    function hideControls() {
        open = false
    }

    function hideMenu() {
        if (menuLoader.item) {
            menuLoader.item.hide()
        }
    }

    width: parent.width
    height: column.height + (_isLandscape ? Theme.paddingLarge : Theme.paddingLarge * 2)
    contentHeight: height
    flickableDirection: Flickable.VerticalFlick

    opacity: Qt.inputMethod.visible ? 0.0 : 1.0
    Behavior on opacity { FadeAnimation {}}

    onActiveChanged: if (!active) hideControls()
    onPositionChanged: if (!slider.pressed) slider.value = position

    background: MediaPlayerPanelBackground { }

    Column {
        id: column

        width: parent.width
        y: panel._isLandscape ? Theme.paddingSmall : Theme.paddingMedium

        Item {
            // slider has some internal padding, use a bit overlapping so extraContent is more attached to it
            width: parent.width
            height: slider.height - Theme.paddingMedium - Theme.paddingSmall

            Slider {
                id: slider

                width: parent.width
                handleVisible: false
                valueText: Format.formatDuration(value / durationScalar, value >= (3600 * durationScalar) ? Format.DurationLong : Format.DurationShort)
                minimumValue: 0
                maximumValue: panel.duration > 0 ? panel.duration : 1
                onReleased: panel.sliderReleased(value)
            }
        }

        Item {
            id: extraContent
            width: column.width
            height: childrenRect.height
        }

        Item {
            width: 1
            height: Theme.paddingMedium
        }

        Row {
            id: navigation
            width: parent.width

            IconButton {
                width: parent.width / 3
                icon.source: "image://theme/icon-m-previous"
                anchors.verticalCenter: parent.verticalCenter
                onClicked: panel.previousClicked()
            }

            IconButton {
                width: parent.width / 3
                icon.source: panel.playing ? "image://theme/icon-m-pause" : "image://theme/icon-m-play"
                onClicked: panel.playPauseClicked()
            }

            IconButton {
                id: forwardButton
                width: parent.width / 3
                icon.source: "image://theme/icon-m-next"
                anchors.verticalCenter: parent.verticalCenter
                onClicked: panel.nextClicked()
            }
        }
    }

    Component {
        id: menuComponent

        PushUpMenu {
            parent: panel
            bottomMargin: panel._isLandscape ? Theme.itemSizeExtraSmall : Theme.itemSizeSmall

            Row {
                id: row
                width: parent.width

                property real childWidth: width / (panel.showAddToPlaylist ? 3 : 2)

                Behavior on childWidth {
                    NumberAnimation { duration: 200 }
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
                    width: row.childWidth
                    anchors.bottom: parent.bottom
                    icon.source: "image://theme/icon-m-shuffle"
                    automaticCheck: false
                    checked: panel.shuffle != MediaPlayerControls.NoShuffle
                    onClicked: panel.shuffleClicked()
                }

                IconButton {
                    width: row.width - 2*row.childWidth
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: -Theme.paddingSmall
                    icon.source: "image://theme/icon-m-new"
                    onClicked: panel.addToPlaylist()

                    opacity: panel.showAddToPlaylist ? 1.0 : 0
                    visible: opacity != 0
                    Behavior on opacity { FadeAnimation {} }
                }

                Switch {
                    width: row.childWidth
                    anchors.bottom: parent.bottom
                    icon.source: panel.repeat == MediaPlayerControls.RepeatTrack ? "image://theme/icon-m-repeat-single"
                                                                                 : "image://theme/icon-m-repeat"
                    automaticCheck: false
                    checked: panel.repeat != MediaPlayerControls.NoRepeat
                    onClicked: panel.repeatClicked()
                }
            }
        }
    }

    Loader {
        id: menuLoader

        sourceComponent: panel.showMenu ? menuComponent : null
    }
}
