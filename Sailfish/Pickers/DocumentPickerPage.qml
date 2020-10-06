/****************************************************************************
**
** Copyright (C) 2013-2016 Jolla Ltd.
** Contact: Raine Mäkeläinen <raine.makelainen@jollamobile.com>
**
****************************************************************************/

import QtQuick 2.0
import QtDocGallery 5.0
import Sailfish.Silica 1.0
import Sailfish.Silica.private 1.0 as Private
import Sailfish.Pickers 1.0
import Sailfish.Gallery 1.0
import "private"

PickerPage {
    id: documentPicker

    property alias _contentModel: documentModel

    //: Placeholder text of document search field in content picker
    //% "Search documents"
    property string _headerPlaceholderText: qsTrId("components_pickers-ph-search_documents")

    //: Empty state text if no documents available. This should be positive and inspiring for the user.
    //% "Copy some documents to device"
    property string _emptyPlaceholderText: qsTrId("components_pickers-la-no-documents-on-device")

    //% "Select document"
    title: qsTrId("components_pickers-he-select_document")

    orientationTransitions: Private.PageOrientationTransition {
        fadeTarget: _background ? listView : __silica_applicationwindow_instance.contentItem
        targetPage: documentPicker
    }

    SilicaListView {
        id: listView

        property bool searchActive

        currentIndex: -1
        anchors.fill: parent
        header: SearchPageHeader {
            width: listView.width
            title: documentPicker.title
            placeholderText: _headerPlaceholderText
            model: documentModel
            visible: active || documentModel.count > 0

            onActiveFocusChanged: {
                if (activeFocus) {
                    listView.currentIndex = -1
                }
            }

            onActiveChanged: listView.searchActive = active
        }

        model: documentModel.model

        ViewPlaceholder {
            text: _emptyPlaceholderText
            enabled: !listView.searchActive && documentModel.count === 0 && (documentModel.status === DocumentGalleryModel.Finished || documentModel.status === DocumentGalleryModel.Idle)
        }

        DocumentModel {
            id: documentModel
        }

        delegate: FileBackgroundItem {
            id: documentItem

            baseName: Theme.highlightText(documentModel.baseName(model.fileName), documentModel.filter, Theme.highlightColor)
            extension: Theme.highlightText(documentModel.extension(model.fileName), documentModel.filter, Theme.highlightColor)
            size: model.fileSize
            // Should be lastModified but QDocumentGallery (or tracker) doesn't return sane values
            // Worth adding QFileInfo Qml wrapper to nemo-qml-plugin-filemanager
            modified: model.lastAccessed
            textFormat: Text.StyledText

            ListView.onAdd: AddAnimation { target: documentItem; duration: _animationDuration }
            ListView.onRemove: RemoveAnimation { target: documentItem; duration: _animationDuration }
            onClicked: _handleSelection(documentModel, index, true)
        }

        VerticalScrollDecorator {}
    }
}
