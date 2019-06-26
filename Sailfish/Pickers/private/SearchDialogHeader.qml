/****************************************************************************
**
** Copyright (C) 2013-2017 Jolla Ltd.
** Contact: Raine Mäkeläinen <raine.makelainen@jollamobile.com>
**
****************************************************************************/

import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Pickers 1.0

FocusScope {
    property alias placeholderText: searchField.placeholderText
    property alias dialog: header.dialog
    property int contentType: ContentType.InvalidType
    property alias searchFieldLeftMargin: searchField.textLeftMargin
    property alias selectedCount: header.selectedCount
    property alias showBack: header.showBack
    property QtObject model
    readonly property bool active: searchField.text.length > 0

    property alias _glassOnly: header._glassOnly

    implicitHeight: col.height

    Column {
        id: col
        width: parent.width

        PickerDialogHeader {
            id: header

            singleSelectionMode: model.singleSelectionMode
        }

        SearchField {
            id: searchField
            width: parent.width
        }

        Binding {
            target: model
            property: "filter"
            value: searchField.text.toLowerCase().trim()
        }
    }
}
