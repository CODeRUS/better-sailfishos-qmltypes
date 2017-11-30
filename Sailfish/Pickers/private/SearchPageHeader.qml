/****************************************************************************
**
** Copyright (C) 2013-2016 Jolla Ltd.
** Contact: Raine Mäkeläinen <raine.makelainen@jollamobile.com>
**
****************************************************************************/

import QtQuick 2.0
import Sailfish.Silica 1.0

FocusScope {
    property alias title: header.title
    property alias placeholderText: searchField.placeholderText
    property alias searchFieldLeftMargin: searchField.textLeftMargin
    property QtObject model
    readonly property bool active: searchField.text.length > 0

    implicitHeight: col.height

    Column {
        id: col
        width: parent.width
        PageHeader {
            id: header
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
