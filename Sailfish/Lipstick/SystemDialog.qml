/****************************************************************************
**
** Copyright (C) 2013 Jolla Ltd.
** Contact: Petri M. Gerdt <petri.gerdt@jollamobile.com>
**
****************************************************************************/

import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Lipstick 1.0

SystemDialogWindow {
    id: dialog

    property alias buttons: layout.buttons
    property alias selectedButton: layout.selectedButton
    property alias contentWidth: layout.contentWidth
    property alias contentHeight: layout.contentHeight

    default property alias _data: layout._data

    width: layout.width
    height: layout.height

    color: Theme.highlightBackgroundColor

    SystemDialogLayout {
        id: layout
        title: dialog.title
    }
}
