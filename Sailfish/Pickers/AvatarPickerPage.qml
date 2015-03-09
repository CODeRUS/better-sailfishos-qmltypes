import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Gallery.private 1.0

ImagePickerPage {
    id: root

    // Readonly
    property url avatarSource
    // Readonly
    property bool cropping: _cropDialog ? _cropDialog.cropping : false
    property Page _cropDialog

    function _customSelectionHandler(model, index, selected) {
        model.updateSelected(index, selected)
        var selectedContentProperties = model.get(index)
        // Hardcoded path will be removed once get JB5266 fixed
        var target = "/home/nemo/.local/share/data/avatars/" + selectedContentProperties.fileName
        _cropDialog = imageEditPage.createObject(root, {
                                                        acceptDestination: pageStack.previousPage(root),
                                                        acceptDestinationAction: PageStackAction.Pop,
                                                        source: selectedContentProperties.url,
                                                        target: target,
                                                        selectedContentProperties: selectedContentProperties,
                                                        orientation: selectedContentProperties.orientation
                                                    })
        pageStack.push(_cropDialog)
    }

    //: Title for avatar picker for selecting avatar
    //% "Select avatar"
    title: qsTrId("components_pickers-he-avatar_picker_title")

    Component {
        id: imageEditPage

        CropDialog {
            id: avatarCropDialog

            property alias source: imageEditPreview.source
            property alias target: imageEditPreview.target
            property alias cropping: imageEditPreview.editInProgress
            property variant selectedContentProperties
            property alias orientation: imageEditPreview.orientation

            allowedOrientations: root.allowedOrientations
            splitOpen: false
            avatarCrop: true
            foreground: ImageEditPreview {
                id: imageEditPreview

                editOperation: ImageEditor.Crop
                isPortrait: splitView.isPortrait
                aspectRatio: 1.0
                splitView: avatarCropDialog
                anchors.fill: parent
                active: !splitView.splitOpen
                explicitWidth: root.width
                explicitHeight: root.height
            }

            onEdited: {
                root.selectedContentProperties = selectedContentProperties
                root.selectedContent = selectedContentProperties.url
                root.avatarSource = target
                root._cropDialog = null
            }

            onCropRequested: imageEditPreview.crop()
        }
    }
}
