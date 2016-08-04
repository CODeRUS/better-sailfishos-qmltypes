/*
 * Copyright (C) 2013-2014 Jolla Ltd.
 * Contact: Robin Burchell <robin.burchell@jolla.com>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; version 2 only.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: base

    property var attachedPage

    property alias title: shareList.title
    property alias path: shareList.path
    property alias mimeType: shareList.mimeType

    default property alias foreground: drawer.data

    property alias open: drawer.open
    property alias menu: shareList.children
    property alias busy: busyIndicator.running

    property url source
    property int indexCount
    property bool _forceNavigation
    property alias drawerVisible: drawer.visible

    property Item documentItem: base

    allowedOrientations: Orientation.All
    backNavigation: drawer.opened || !drawer.visible || _forceNavigation
    forwardNavigation: drawer.opened || _forceNavigation

    function pushAttachedPage() {
        if (pageStack.nextPage(base) === null) {
            pageStack.push(base.attachedPage)
        } else {
            _forceNavigation = true
            pageStack.navigateForward()
            _forceNavigation = false
        }
    }

    BusyIndicator { id: busyIndicator; anchors.centerIn: parent; size: BusyIndicatorSize.Large; z: 1 }

    Component.onDestruction: window.documentItem = null
    Drawer {
        id: drawer

        anchors.fill: parent
        dock: base.orientation == Orientation.Portrait || base.orientation == Orientation.InvertedPortrait
                ? Dock.Top
                : Dock.Left

        hideOnMinimize: true

        onOpenChanged: {
            if (open && pageStack.nextPage(base) === null)
                pageStack.pushAttached(base.attachedPage)
        }

        background: DocumentsSharingList {
            id: shareList

            visualParent: base
            anchors.fill: parent

            PullDownMenu {
                MenuItem {
                    //: Show the Details page
                    //% "Details"
                    text: qsTrId("sailfish-office-me-details_page");
                    onClicked: pageStack.push(detailsPage, {
                                                  source: base.source,
                                                  indexCount: base.indexCount,
                                                  mimeType: base.mimeType
                                              })
                }
            }
        }
    }

    onStatusChanged: {
        if (status == PageStatus.Active) {
            drawer.open = false
            window.documentItem = documentItem
        }
    }

    Component {
        id: detailsPage

        DetailsPage { }
    }
}
