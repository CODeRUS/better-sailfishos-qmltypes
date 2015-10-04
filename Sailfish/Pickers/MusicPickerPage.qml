import QtQuick 2.0
import QtDocGallery 5.0
import Sailfish.Silica 1.0
import Sailfish.Silica.private 1.0 as Private
import Sailfish.Pickers 1.0
import Sailfish.Media 1.0
import Sailfish.Gallery 1.0

PickerPage {
    id: musicPicker

    orientationTransitions: Private.PageOrientationTransition {
        fadeTarget: _background ? listView : __silica_applicationwindow_instance.contentItem
        targetPage: musicPicker
    }

    MediaFormatter {
        id: formatter
    }

    SilicaListView {
        id: listView

        property bool searchActive

        currentIndex: -1
        anchors.fill: parent
        header: SearchPageHeader {
            width: listView.width
            title: musicPicker.title

            //: Placeholder text of music search field in content picker
            //% "Search music"
            placeholderText: qsTrId("components_pickers-ph-search_music")
            model: musicModel
            visible: active || musicModel.count > 0

            onActiveFocusChanged: {
                if (activeFocus) {
                    listView.currentIndex = -1
                }
            }

            onActiveChanged: listView.searchActive = active
        }

        model: musicModel.model

        ViewPlaceholder {
            //: Empty state text if no music available. This should be positive and inspiring for the user.
            //% "Copy some music to device"
            text: qsTrId("components_pickers-la-no-music-on-device")
            enabled: !listView.searchActive && musicModel.count === 0 && (musicModel.status === DocumentGalleryModel.Finished || musicModel.status === DocumentGalleryModel.Idle)
        }

        MusicModel {
            id: musicModel
        }

        delegate: MediaListItem {
            id: mediaListItem
            highlighted: down || model.selected
            duration: model.duration
            title: Theme.highlightText(formatter.formatSong(model.title), musicModel.filter, Theme.highlightColor)
            subtitle: Theme.highlightText(formatter.formatArtist(model.artist) + " | " +
                                          formatter.formatAlbum(model.albumTitle), musicModel.filter, Theme.highlightColor)
            textFormat: Text.StyledText
            ListView.onAdd: AddAnimation { target: mediaListItem; duration: _animationDuration }
            ListView.onRemove: RemoveAnimation { target: mediaListItem; duration: _animationDuration }
            onClicked: _handleSelection(musicModel, index, true)
            _showPress: false

            HighlightItem {
                anchors.fill: parent
                z: -1
                highlightOpacity: Theme.highlightBackgroundOpacity
                active: highlighted
            }
        }

        VerticalScrollDecorator {}
    }
}
