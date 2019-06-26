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
import org.nemomobile.configuration 1.0

SystemDialogWindow {
    id: dialog

    property alias contentHeight: layout.contentHeight
    property alias bottomPadding: layout.bottomPadding
    property alias allowedOrientations: window.allowedOrientations
    readonly property alias orientation: window.orientation
    readonly property alias screenHeight: window._screenHeight
    property bool autoDismiss: true

    property bool _closing
    default property alias _data: layout._data

    property alias __silica_applicationwindow_instance: window

    signal dismissed()

    function activate() {
        _closing = false
        showFullScreen()
        raise()
    }

    function dismiss() {
        _closing = true
        lower()
    }

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

        _backgroundVisible: true
        cover: null
        allowedOrientations: lipstickSettings.dialog_orientation || QtQuick.Screen.primaryOrientation
        focus: true

        _backgroundRect: {
            switch (window._rotatingItem.rotation) {
            case 90:
            case -270:
                return Qt.rect(width - layout.contentHeight, 0, layout.contentHeight, height)
            case 180:
            case -180:
                return Qt.rect(0, height - layout.contentHeight, width, layout.contentHeight)
            case 270:
            case -90:
                return Qt.rect(0, 0, layout.contentHeight, height)
            case 0:
            case 360:
            default:
                return Qt.rect(0, 0, width, layout.contentHeight)
            }
        }
    }

    ConfigurationGroup {
        id: lipstickSettings
        path: "/desktop/lipstick-jolla-home"

        property int dialog_orientation
    }

    SystemDialogLayout {
        id: layout
        // This is declared outside of the initialPage component so its members can be aliased,
        // but parented to that page when it exists so that it receives orientation transforms
        // and transitions.
        parent: window.pageStack.currentPage ? window.pageStack.currentPage : window.contentItem

        focus: !dialog._closing

        onDismiss: {
            if (dialog.autoDismiss) {
                dialog._closing = true
                dialog.lower()
                dialog.dismissed()
            }
        }
    }
}
