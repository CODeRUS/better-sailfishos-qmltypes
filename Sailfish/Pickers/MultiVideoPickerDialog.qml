import QtQuick 2.0
import QtDocGallery 5.0
import Sailfish.Silica 1.0
import Sailfish.Gallery 1.0
import Sailfish.Pickers 1.0

PickerDialog {
    id: videoPickerDialog

    Formatter {
        id: formatter
    }

    ImageGridView {
        id: gridView

        property bool searchActive

        highlightEnabled: false
        anchors.fill: parent
        columnCount: isLandscape ? 4 : 2

        header: SearchDialogHeader {
            width: gridView.width
            dialog: videoPickerDialog
            //: Videos search field placeholder text
            //% "Search videos"
            placeholderText: qsTrId("components_pickers-ph-search_videos")
            model: videoModel
            contentType: ContentType.Video
            visible: active || videoModel.count > 0

            onActiveFocusChanged: {
                if (activeFocus) {
                    gridView.currentIndex = -1
                }
            }

            onActiveChanged: gridView.searchActive = active
        }

        model: videoModel.model

        VideoModel {
            id: videoModel
            selectedModel: _selectedModel
        }

        ViewPlaceholder {
            //: Empty state text if no videos available. This should be positive and inspiring for the user.
            //% "Copy some videos to device"
            text: qsTrId("components_pickers-la-no-videos-on-device")
            enabled: !gridView.searchActive && videoModel.count === 0 && (videoModel.status === DocumentGalleryModel.Finished || videoModel.status === DocumentGalleryModel.Idle)
        }

        delegate: ThumbnailVideo {
            id: thumbnail
            source: model.url
            size: gridView.cellWidth
            mimeType: model.mimeType
            duration: model.duration > 3600 ? formatter.formatDuration(model.duration, Formatter.DurationLong) :
                                              formatter.formatDuration(model.duration, Formatter.DurationShort)
            title: model.title
            GridView.onAdd: AddAnimation { target: thumbnail; duration: _animationDuration }
            GridView.onRemove: RemoveAnimation { target: thumbnail; duration: _animationDuration }
            onClicked: videoModel.updateSelected(index, !selected)
            HighlightItem {
                anchors.fill: parent
                active: model.selected || parent.down
            }
        }
    }
}
