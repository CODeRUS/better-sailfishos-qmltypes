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
