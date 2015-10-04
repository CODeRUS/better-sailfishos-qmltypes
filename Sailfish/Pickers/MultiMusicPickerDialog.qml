import QtQuick 2.0
import QtDocGallery 5.0
import Sailfish.Silica 1.0
import Sailfish.Silica.private 1.0 as Private
import Sailfish.Pickers 1.0
import Sailfish.Gallery 1.0
import Sailfish.Media 1.0

PickerDialog {
    id: musicPickerDialog

    property bool preview

    orientationTransitions: Private.PageOrientationTransition {
        fadeTarget: _background ? listView : __silica_applicationwindow_instance.contentItem
        targetPage: musicPickerDialog
    }

    MediaFormatter {
        id: formatter
    }

    SilicaListView {
        id: listView

        property bool searchActive

        currentIndex: -1
        anchors.fill: parent
        header: SearchDialogHeader {
            width: listView.width
            dialog: musicPickerDialog
            //: Placeholder text of music search field in content picker
            //% "Search music"
            placeholderText: qsTrId("components_pickers-ph-search_music")
            model: musicModel
            contentType: ContentType.Music
            visible: active || musicModel.count > 0
            _glassOnly: musicPickerDialog._background

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
            selectedModel: _selectedModel
            singleSelectionMode: preview
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
            _showPress: false

            onClicked: {
                musicModel.updateSelected(index, !selected)
                if (preview) {
                    var wasSameModel = selectedContent == _selectedModel
                    selectedContent = _selectedModel
                    if (wasSameModel) {
                        selectedContentChanged()
                    }
                }
            }

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
