/****************************************************************************
**
** Copyright (C) 2013 Jolla Ltd.
** Contact: Bea Lam <bea.lam@jollamobile.com>
**
****************************************************************************/

import QtQuick 2.0
import Sailfish.Silica 1.0

Column {
    width: parent.width
    spacing: Theme.paddingLarge

    BusyIndicator {
        anchors.horizontalCenter: parent.horizontalCenter
        running: parent.visible
        size: BusyIndicatorSize.Large
    }

    Label {
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width - Theme.padding*2
        wrapMode: Text.WordWrap
        color: Theme.highlightColor
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: Theme.fontSizeSmall

        //: Shown while page is loading
        //% "Loading"
        text: qsTrId("startupwizard-la-loading")
    }
}
