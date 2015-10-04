import QtQuick 2.0
import QtDocGallery 5.0
import Sailfish.Silica 1.0
import Sailfish.Silica.private 1.0 as Private
import Sailfish.Gallery 1.0
import Sailfish.Pickers 1.0

PickerPage {
    id: imagePicker

    orientationTransitions: Private.PageOrientationTransition {
        fadeTarget: _background ? gridView : __silica_applicationwindow_instance.contentItem
        targetPage: imagePicker
    }

    ImageGridView {
        id: gridView

        property bool searchActive

        anchors.fill: parent
        header: SearchPageHeader {
            id: searchHeader
            title: imagePicker.title
            width: gridView.width

            //: Images search field placeholder text
            //% "Search images"
            placeholderText: qsTrId("components_pickers-ph-search_images")
            model: imageModel
            visible: active || imageModel.count > 0

            onActiveFocusChanged: {
                if (activeFocus) {
                    gridView.currentIndex = -1
                }
            }

            onActiveChanged: gridView.searchActive = active
        }

        model: imageModel.model

        ViewPlaceholder {
            //: Empty state text if no images available. This should be positive and inspiring for the user.
            //% "Take some photos"
            text: qsTrId("components_pickers-la-no-images-on-device")
            enabled: !gridView.searchActive && imageModel.count === 0 && (imageModel.status === DocumentGalleryModel.Finished || imageModel.status === DocumentGalleryModel.Idle)
        }

        ImageModel {
            id: imageModel
        }

        delegate: ThumbnailImage {
            id: thumbnail
            source: model.url
            size: gridView.cellWidth
            GridView.onAdd: AddAnimation { target: thumbnail; duration: _animationDuration }
            GridView.onRemove: RemoveAnimation { target: thumbnail; duration: _animationDuration }
            onClicked: _customSelectionHandler(imageModel, index, true)
        }
    }
}
