/****************************************************************************************
**
** Copyright (c) 2019-2020 Open Mobile Platform LLC.
** All rights reserved.
**
** License: Proprietary.
**
****************************************************************************************/

import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Accounts 1.0
import Sailfish.Lipstick 1.0
import com.jolla.eventsview.nextcloud 1.0
import Sailfish.Silica.private 1.0

NotificationGroupItem {
    id: root

    property int accountId
    property bool collapsed
    property bool showingInActiveView
    property bool userRemovable: (eventModel.supportedActions & NextcloudEventModel.DeleteEvent)
                                 || eventModel.supportedActions & NextcloudEventModel.DeleteAllEvents
    property int hasRemovableItems: userRemovable && listView.count > 0
    property alias mainContentHeight: listView.contentHeight
    property bool hasOnlyOneItem: eventModel.count === 1

    property int _modelCount: listView.model.count
    property int _expansionThreshold: 5
    property int _expansionMaximum: 10
    property string _hostUrl

    signal expanded(int itemPosY)

    function findMatchingRemovableItems(filterFunc, matchingResults) {
        if (!userRemovable || !filterFunc(groupHeader)) {
            return
        }
        matchingResults.push(groupHeader)
        var yPos = listView.contentY
        while (yPos < listView.contentHeight) {
            var item = listView.itemAt(0, yPos)
            if (!item) {
                break
            }
            if (item.userRemovable === true) {
                if (!filterFunc(item)) {
                    return false
                }
                matchingResults.push(item)
            }
            yPos += item.height
        }
    }

    function removeAllNotifications() {
        if (groupHeader.userRemovable) {
            removeComponent.createObject(root, { "target": root })
        }
    }

    visible: _modelCount > 0
    width: parent.width
    height: _modelCount === 0 ? 0 : expansionToggle.y + expansionToggle.height
    draggable: groupHeader.draggable

    onSwipedAway: if (model) removeComponent.createObject(root, { "target": root })

    NotificationGroupHeader {
        id: groupHeader

        name: account.displayName
        iconSource: "image://theme/graphic-service-nextcloud"
        userRemovable: eventModel.supportedActions & NextcloudEventModel.DeleteAllEvents
        extraBackgroundPadding: root.hasOnlyOneItem
        enabled: !housekeeping

        groupHighlighted: root.highlighted
        onTriggered: {
            if (root._hostUrl.length > 0) {
                Qt.openUrlExternally(root._hostUrl)
            }
        }
    }

    Component {
        id: removeComponent
        RemoveAnimation {
            running: true

            onStopped: {
                if (target === root) {
                    // Delay deleting all events until animation has finished to avoid UI stutter.
                    eventModel.deleteAllEvents()
                }
            }
        }
    }

    ListView {
        id: listView
        anchors.top: groupHeader.bottom
        width: parent.width
        height: Screen.height * 1000 // Ensures the view is fully populated without needing to bind height: contentHeight

        interactive: false
        model: boundedModel
    }

    NotificationExpansionButton {
        id: expansionToggle

        y: groupHeader.height + listView.contentHeight
        expandable: eventModel.count > _expansionThreshold
                    || eventModel.count > _expansionMaximum
        enabled: expandable && !groupHeader.drag.active

        title: root.collapsed
               ? defaultTitle
                 //% "Show more in Nextcloud"
               : qsTrId("lipstick-jolla-home-la-show-more-in-nextcloud")
        remainingCount: eventModel.count - boundedModel.count

        onClicked: {
            if (root.collapsed) {
                var itemPosY = listView.contentHeight + groupHeader.height - Theme.paddingLarge
                root.expanded(itemPosY)
            } else {
                if (root._hostUrl.length > 0) {
                    Qt.openUrlExternally(root._hostUrl)
                }
            }
        }
    }

    NextcloudEventCache {
        id: evCache
    }

    Timer {
        id: refreshEventModelTimer
        interval: 5 * 60 * 1000
        repeat: true
        running: root.showingInActiveView
        onRunningChanged: {
            if (running) {
                eventModel.refresh()
            }
        }
        onTriggered: eventModel.refresh()
    }

    NextcloudEventModel {
        id: eventModel

        eventCache: evCache
        accountId: root.accountId
    }

    BoundedModel {
        id: boundedModel
        model: eventModel
        maximumCount: !root.collapsed ? root._expansionMaximum : root._expansionThreshold

        delegate: NextcloudFeedItem {
            id: delegateItem

            subject: model.eventSubject
            message: model.eventText
            icon.source: imageDownloader.imagePath != ""
                         ? imageDownloader.imagePath
                         : "image://theme/graphic-service-nextcloud" // placeholder is not square: "image://theme/icon-l-nextcloud"
            timestamp: model.timestamp
            eventUrl: model.eventUrl
            userRemovable: eventModel.supportedActions & NextcloudEventModel.DeleteEvent
            enabled: !housekeeping || !root.hasOnlyOneItem
            groupHighlighted: root.highlighted
            contentLeftMargin: groupHeader.textLeftMargin

            lastItem: model.index === boundedModel.count - 1

            onRemoveRequested: {
                removeComponent.createObject(delegateItem, { "target": delegateItem })
                eventModel.deleteEventAt(model.index)
            }

            NextcloudEventImageDownloader {
                id: imageDownloader
                accountId: eventModel.accountId
                eventCache: evCache
                eventId: model.eventId
            }
        }
    }

    Account {
        id: account

        identifier: eventModel.accountId

        onStatusChanged: {
            if (status === Account.Initialized) {
                var config = account.configurationValues("nextcloud-posts")
                if (config) {
                    root._hostUrl = config.server_address || ""
                }
            }
        }
    }
}
