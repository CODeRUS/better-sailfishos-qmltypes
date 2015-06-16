/****************************************************************************
**
** Copyright (C) 2013 Jolla Ltd.
** Contact: Raine Mäkeläinen <raine.makelainen@jollamobile.com>
**
****************************************************************************/

import QtQuick 2.0
import QtDocGallery 5.0
import Sailfish.Silica 1.0
import Sailfish.Pickers 1.0
import Sailfish.Gallery 1.0

PickerDialog {
    id: documentPickerDialog

    SilicaListView {
        id: listView

        property bool searchActive

        currentIndex: -1
        anchors.fill: parent
        header: SearchDialogHeader {
            width: listView.width
            dialog: documentPickerDialog
            //: Placeholder text of document search field in content picker
            //% "Search documents"
            placeholderText: qsTrId("components_pickers-ph-search_documents")
            model: documentModel
            contentType: ContentType.Document
            visible: active || documentModel.count > 0
            _glassOnly: documentPickerDialog._background

            onActiveFocusChanged: {
                if (activeFocus) {
                    listView.currentIndex = -1
                }
            }

            onActiveChanged: listView.searchActive = active
        }

        model: documentModel.model

        ViewPlaceholder {
            //: Empty state text if no documents available. This should be positive and inspiring for the user.
            //% "Copy some documents to device"
            text: qsTrId("components_pickers-la-no-documents-on-device")
            enabled: !listView.searchActive && documentModel.count === 0 && (documentModel.status === DocumentGalleryModel.Finished || documentModel.status === DocumentGalleryModel.Idle)
        }

        DocumentModel {
            id: documentModel
            selectedModel: _selectedModel
        }

        delegate: DocumentItem {
            id: documentItem
            leftMargin: listView.headerItem.searchFieldLeftMargin
            baseName: Theme.highlightText(documentModel.baseName(model.fileName), documentModel.filter, Theme.highlightColor)
            extension: Theme.highlightText(documentModel.extension(model.fileName), documentModel.filter, Theme.highlightColor)
            selected: model.selected

            ListView.onAdd: AddAnimation { target: documentItem; duration: _animationDuration }
            ListView.onRemove: RemoveAnimation { target: documentItem; duration: _animationDuration }
            onClicked: documentModel.updateSelected(index, !selected)
        }

        VerticalScrollDecorator {}
    }
}
