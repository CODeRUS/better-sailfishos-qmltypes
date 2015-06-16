/****************************************************************************
**
** Copyright (C) 2013 Jolla Ltd.
** Contact: Raine Mäkeläinen <raine.makelainen@jollamobile.com>
**
****************************************************************************/

import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Contacts 1.0
import Sailfish.Gallery.private 1.0
import org.nemomobile.contacts 1.0
import "private"

SplitViewPage {
    id: imageEditor

    property alias source: imageEditPreview.source
    property alias target: imageEditPreview.target
    // To align this with SplitViewDialog
    property alias splitOpen: imageEditor.open
    property alias splitOpened: imageEditor.opened

    property Page _contactPicker
    property bool _contactSaveRequested

    property string _avatarPath
    property string _contactId

    onIsPortraitChanged: imageEditPreview.resetScale()

    signal edited

    open: true

    function _pageActivating() {
        imageEditor.foreground = imageEditPreview
        imageEditPreview.resetParent(imageEditor.foregroundItem)
        imageEditPreview.splitView = imageEditor
        imageEditPreview.editOperation = ImageEditor.None
    }

    onStatusChanged: {
        if (status == PageStatus.Activating) {
            _pageActivating()
        }
    }

    onEdited: {
        if (_contactSaveRequested) {
            if (_contactId == "" || _avatarPath == "") {
                console.log("Invalid contact id or avatar path")
                return
            }

            var model = peopleModelComponent.createObject(imageEditor)
            if (!model) {
                console.log("Failed to create contact model!")
                return
            }

            var person = model.personById(_contactId)
            if (!person) {
                console.log("Failed to fetch person with id: ", _contactId)
                return
            }

            person.avatarPath = _avatarPath

            // Remove old avatar file(s)
            AvatarFileHandler.removeOldAvatars(_contactId, _avatarPath);

            if (!model.savePerson(person)) {
                console.log("Failed to save avatar image to the contact with id: ", _contactId)
                return
            }

            _contactSaveRequested = false
            model.destroy(1000)
        }
    }

    Component {
        id: peopleModelComponent
        PeopleModel {
            filterType: PeopleModel.FilterAll
        }
    }

    background: SilicaListView {
        anchors.fill: parent

        //: "Image editing page title"
        //% "Edit"
        header: PageHeader { title: qsTrId("components_gallery-he-edit") }

        delegate: BackgroundItem {
            id: operationDelegate

            enabled: !imageEditPreview.editInProgress
                     && imageEditPreview.status ==Image.Ready
            opacity: enabled ? 1 : 0.5

            IconButton {
                id: icon
                x: Theme.horizontalPageMargin
                icon.source: model.icon
                icon.opacity: 1.0
                down: operationDelegate.highlighted
                enabled: false
                anchors.verticalCenter: parent.verticalCenter
            }

            Label {
                color: highlighted ? Theme.highlightColor : Theme.primaryColor
                text: model.text
                anchors {
                    left: icon.right
                    right: parent.right
                    rightMargin: Theme.horizontalPageMargin
                    verticalCenter: parent.verticalCenter
                }
            }

            onClicked: {
                if (model.type === ImageEditor.Crop) {
                    imageEditPreview.splitView = pageStack.push(aspectRatioDialogComponent,
                                                               { splitOpen: false })
                    imageEditPreview.editOperation = model.type
                    imageEditPreview.resetParent(imageEditPreview.splitView.foregroundItem)
                } else
                if (model.type === ImageEditor.Rotate) {
                    imageEditPreview.splitView = pageStack.push(rotateDialogComponent,
                                                                { splitOpen: true })
                    imageEditPreview.editOperation = model.type
                    imageEditPreview.resetParent(imageEditPreview.splitView.foregroundItem)
                }
            }
        }

        model: ImageEditOperationModel {}

    }



    // Shared between ImageEditPage and CropDialog so that state
    // of zoom is correct.
    // TODO: MarkoM: I think ImageEditPreview is doing too much. We should redesign
    //               to have e.g. crop specific preview only. Current implementation
    //               is way too complex and not very modular.
    foreground: ImageEditPreview {
        id: imageEditPreview

        function resetParent(parentItem) {
            parent = null
            parent = parentItem
        }

        isPortrait: splitView.isPortrait
        splitView: imageEditor
        width: parent ? parent.width : 0
        height: parent ? parent.height : 0
        active: pageStack.currentPage === imageEditor ? false : !splitView.splitOpen
        explicitWidth: imageEditor.width
        explicitHeight: imageEditor.height
    }

    Component {
        id: aspectRatioDialogComponent
        CropDialog {
            // Prepare acceptDestionation for contact picking
            function prepareAcceptDestination() {
                if (imageEditPreview.aspectRatioType == "avatar") {
                    if (!_contactPicker) {
                        _contactPicker = contactPickerPage.createObject(imageEditor)
                    }
                    acceptDestinationAction = PageStackAction.Push
                    acceptDestination = _contactPicker
                    _contactSaveRequested = false
                } else {
                    acceptDestinationAction = PageStackAction.Pop
                    acceptDestination = undefined
                }
            }

            allowedOrientations: imageEditor.allowedOrientations
            foreground: imageEditPreview
            onEdited: imageEditor.edited()
            onSplitOpenedChanged: {
                if (!splitOpened) {
                    prepareAcceptDestination()
                }
            }

            onCropRequested: {
                if (imageEditPreview.aspectRatioType != "avatar") {
                    // Reset back to empty
                    imageEditPreview.target = ""
                    imageEditPreview.crop()
                }
                // For avatars crop will be triggered when contact selected
            }

            onCropCanceled: {
                imageEditPreview.resetScale()
            }

            Component.onCompleted: prepareAcceptDestination()
        }
    }

    Component {
        id: rotateDialogComponent
        RotateDialog {
            id: rotateDialog
            foreground: imageEditPreview

            onRotate: {
                imageEditPreview.previewRotationAnimEnabled = true
                // Rotate in steps, but not when there's an ongoing transition
                if (imageEditPreview.previewRotation % 90 == 0) {
                    imageEditPreview.previewRotation = imageEditPreview.previewRotation + angle
                }
                imageEditPreview.previewRotationAnimEnabled = false
            }

            onRotateRequested: {
                imageEditPreview.target = ""
                imageEditPreview.rotateImage()
            }

            onRotateCanceled: {
                imageEditPreview.previewRotation = 0
            }
        }
    }

    Component {
        id: contactPickerPage

        ContactSelectPage {
            onContactClicked: {
                imageEditPreview.target = AvatarFileHandler.createNewAvatarFileName(contact.id)
                imageEditor._avatarPath = imageEditPreview.target
                imageEditor._contactId = contact.id
                _contactSaveRequested = true
                imageEditPreview.crop()
                // Do all needed page activation states before popping pages
                imageEditor._pageActivating()
                _navigation = PageNavigation.Forward
                pageStack.pop(imageEditor)
            }
        }
    }        
}
