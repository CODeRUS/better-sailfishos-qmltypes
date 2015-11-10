/*
 * Copyright (C) 2012-2015 Jolla Ltd.
 *
 * The code in this file is distributed under multiple licenses, and as such,
 * may be used under any one of the following licenses:
 *
 *   - GNU General Public License as published by the Free Software Foundation;
 *     either version 2 of the License (see LICENSE.GPLv2 in the root directory
 *     for full terms), or (at your option) any later version.
 *   - GNU Lesser General Public License as published by the Free Software
 *     Foundation; either version 2.1 of the License (see LICENSE.LGPLv21 in the
 *     root directory for full terms), or (at your option) any later version.
 *   - Alternatively, if you have a commercial license agreement with Jolla Ltd,
 *     you may use the code under the terms of that license instead.
 *
 * You can visit <https://sailfishos.org/legal/> for more information
 */

// -*- qml -*-

import QtQuick 2.0
import Sailfish.Silica 1.0
import com.jolla.mediaplayer 1.0

FocusScope {
    id: scope

    property alias model: listView.model
    property alias count: listView.count
    property alias delegate: listView.delegate
    property alias header: headerContainer.children
    property alias headerItem: listView.headerItem
    property alias footer: footerContainer.children
    property alias contentItem: listView.contentItem
    property alias contentWidth: listView.contentWidth
    default property alias _data: listView.flickableData

    anchors.fill: parent

    SilicaListView {
        id: listView

        anchors.fill: parent

        header: Item {
            onYChanged: headerContainer.y = y
            height: headerContainer.height
        }

        footer: Item {
            onYChanged: footerContainer.y = y
            height: footerContainer.height
        }

        VerticalScrollDecorator {}
    }

    /* This is a hack to place the header and footer over the */
    /* SilicaListView to avoid losing the focus upon new search filters, */
    /* as explained at JB#19789 */
    Item {
        y: listView.contentItem.y
        height: listView.contentItem.height

        Column {
            id: headerContainer
            width: scope.width
        }

        Column {
            id: footerContainer
            width: scope.width
        }
    }
}
