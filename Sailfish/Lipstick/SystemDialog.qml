/****************************************************************************
**
** Copyright (C) 2013 Jolla Ltd.
** Contact: Petri M. Gerdt <petri.gerdt@jollamobile.com>
**
****************************************************************************/

import QtQuick 2.0
import QtQuick.Window 2.1 as QtQuick
import Sailfish.Silica 1.0
import Sailfish.Lipstick 1.0

SystemDialogWindow {
    id: dialog

    property alias buttons: layout.buttons
    property alias buttonCount: layout.buttonCount
    property alias selectedButton: layout.selectedButton
    property alias contentWidth: layout.contentWidth
    property alias contentHeight: layout.contentHeight

    default property alias _data: layout._data

    property bool _closing

    width: Screen.width
    height: Screen.height

    onVisibilityChanged: {
        if (_closing && visibility == QtQuick.Window.Hidden) {
            dialog.close()
        } else {
            _closing = false
        }
    }

    SystemDialogApplicationWindow {
        id: window

        allowedOrientations: Orientation.Portrait
        _backgroundVisible: false
        cover: null
    }

    SystemDialogLayout {
        id: layout
        // This is declared outside of the initialPage component so its members can be aliased,
        // but parented to that page when it exists so that it receives orientation transforms
        // and transitions.
        parent: window.pageStack.currentPage ? window.pageStack.currentPage : window.contentItem
        title: dialog.title
        anchors.fill: parent
        headerLayout: !window.pageStack.currentPage
                    || window.pageStack.currentPage.orientation == Orientation.Portrait
                    || window.pageStack.currentPage.orientation == Orientation.PortraitInverted
                ? Qt.Vertical
                : Qt.Horizontal
        maximumHeight: Math.min(layout.height, window._rotatingItem.height * 2 / 3)

        onDismiss: {
            dialog._closing = true
            dialog.lower()
        }
    }
}
