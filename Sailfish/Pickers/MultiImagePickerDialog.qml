import QtQuick 2.0
import QtDocGallery 5.0
import Sailfish.Silica 1.0
import Sailfish.Silica.private 1.0 as Private
import Sailfish.Gallery 1.0
import Sailfish.Pickers 1.0

PickerDialog {
    id: imagePickerDialog

    orientationTransitions: Private.PageOrientationTransition {
        fadeTarget: _background ? gridView : __silica_applicationwindow_instance.contentItem
        targetPage: imagePickerDialog
    }

    ImageGridView {
        id: gridView

        property bool searchActive

        highlightEnabled: false
        anchors.fill: parent
        header: SearchDialogHeader {
            width: gridView.width
            dialog: imagePickerDialog
            //: Images search field placeholder text
            //% "Search images"
            placeholderText: qsTrId("components_pickers-ph-search_images")
            model: imageModel
            contentType: ContentType.Image
            visible: active || imageModel.count > 0
            _glassOnly: imagePickerDialog._background

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
            selectedModel: _selectedModel
        }

        delegate: ThumbnailImage {
            id: thumbnail
            source: model.url
            size: gridView.cellWidth
            GridView.onAdd: AddAnimation { target: thumbnail; duration: _animationDuration }
            GridView.onRemove: RemoveAnimation { target: thumbnail; duration: _animationDuration }
            onClicked: imageModel.updateSelected(index, !selected)
            HighlightItem {
                anchors.fill: parent
                active: model.selected || parent.down
            }
        }
    }
}
