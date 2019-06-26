/****************************************************************************
**
** Copyright (C) 2017 Jolla Ltd.
** Contact: Raine Mäkeläinen <raine.makelainen@jolla.com>
**
****************************************************************************/

import QtQuick 2.0
import Sailfish.Silica 1.0

DialogHeader {
    id: header

    property bool showBack
    property bool singleSelectionMode
    property int selectedCount

    //: Dialog header cancel text as "Back"
    //% "Back"
    cancelText: showBack ? qsTrId("components_pickers-he-multiselect_dialog_back") : defaultCancelText
    spacing: 0

    acceptText: {
        var text = dialog.acceptText.length ? dialog.acceptText : defaultAcceptText
        if (singleSelectionMode) {
            return text
        } else {
            //: Multi content picker number of selected content items
            //% "Accept %n"
            return selectedCount ? qsTrId("components_pickers-he-multipicker_accept", selectedCount) : text
        }
    }
}
