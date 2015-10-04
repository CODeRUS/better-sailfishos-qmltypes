import QtQuick 2.0
import QtDocGallery 5.0
import Sailfish.Silica 1.0
import Sailfish.Silica.private 1.0 as Private
import Sailfish.Gallery 1.0
import Sailfish.Pickers 1.0

PickerPage {
    id: videoPicker

    orientationTransitions: Private.PageOrientationTransition {
        fadeTarget: _background ? gridView : __silica_applicationwindow_instance.contentItem
        targetPage: videoPicker
    }

    Formatter {
        id: formatter
    }

    ImageGridView {
        id: gridView

        property bool searchActive

        anchors.fill: parent
        // reference column width: 960 / 4
        columnCount: Math.floor(width / (Theme.pixelRatio * 240))

        header: SearchPageHeader {
            id: searchHeader
            title: videoPicker.title
            width: gridView.width

            //: Videos search field placeholder text
            //% "Search videos"
            placeholderText: qsTrId("components_pickers-ph-search_videos")
            model: videoModel
            visible: active || videoModel.count > 0

            onActiveFocusChanged: {
                if (activeFocus) {
                    gridView.currentIndex = -1
                }
            }

            onActiveChanged: gridView.searchActive = active
        }

        model: videoModel.model

        ViewPlaceholder {
            //: Empty state text if no videos available. This should be positive and inspiring for the user.
            //% "Copy some videos to device"
            text: qsTrId("components_pickers-la-no-videos-on-device")
            enabled: !gridView.searchActive && videoModel.count === 0 && (videoModel.status === DocumentGalleryModel.Finished || videoModel.status === DocumentGalleryModel.Idle)
        }

        VideoModel {
            id: videoModel
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
            onClicked: _handleSelection(videoModel, index, true)
        }
    }
}
