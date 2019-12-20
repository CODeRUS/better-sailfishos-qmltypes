/****************************************************************************
**
** Copyright (C) 2013-2016 Jolla Ltd.
** Contact: Raine Mäkeläinen <raine.makelainen@jollamobile.com>
**
****************************************************************************/

import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Pickers 1.0
import Sailfish.Gallery.private 1.0

ImagePickerPage {
    id: root

    // Readonly
    property url avatarSource
    // Readonly
    property bool cropping: _cropDialog && _cropDialog.editInProgress
    property Page _cropDialog

    function _customSelectionHandler(model, index, selected) {
        model.updateSelected(index, selected)
        var selectedContentProperties = model.get(index)
        var target = AvatarFileHandler.createNewAvatarFileName(selectedContentProperties.fileName)
        _cropDialog = cropDialog.createObject(root, {
           acceptDestination: pageStack.previousPage(root),
           acceptDestinationAction: PageStackAction.Pop,
           source: selectedContentProperties.url,
           target: target,
           selectedContentProperties: selectedContentProperties
        })
        pageStack.animatorPush(_cropDialog)
    }

    //: Title for avatar picker for selecting avatar
    //% "Select avatar"
    title: qsTrId("components_pickers-he-avatar_picker_title")

    Component {
        id: cropDialog

        AvatarCropDialog {
            property var selectedContentProperties
            allowedOrientations: root.allowedOrientations

            onEdited: {
                root.selectedContentProperties = selectedContentProperties
                root.selectedContent = selectedContentProperties.url
                root.avatarSource = target
                root._cropDialog = null
            }
        }
    }
}
