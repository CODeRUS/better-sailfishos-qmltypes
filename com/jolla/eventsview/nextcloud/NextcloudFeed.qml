/****************************************************************************************
**
** Copyright (c) 2019 Open Mobile Platform LLC.
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

Item {
    id: root

    property int accountId
    property bool collapsed
    property bool showingInActiveView
    property bool userRemovable: (eventModel.supportedActions & NextcloudEventModel.DeleteEvent)
                                 || eventModel.supportedActions & NextcloudEventModel.DeleteAllEvents
    property int hasRemovableItems: userRemovable && listView.count > 0
    property alias mainContentHeight: listView.contentHeight

    property int _modelCount: listView.model.count
    property int _expansionThreshold: 5
    property int _expansionMaximum: 10
    property bool _manuallyExpanded
    property string _hostUrl

    signal expanded(int itemPosY)

    function findMatchingRemovableItems(filterFunc, matchingResults) {
        if (!userRemovable || !filterFunc(headerItem)) {
            return
        }
        matchingResults.push(headerItem)
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
        if (headerItem.userRemovable) {
            removeComponent.createObject(root, { "target": root })
        }
    }

    visible: _modelCount > 0
    width: parent.width
    height: _modelCount === 0 ? 0 : expansionToggle.y + expansionToggle.height

    onCollapsedChanged: {
        if (!collapsed) {
            root._manuallyExpanded = false
        }
    }

    NotificationGroupHeader {
        id: headerItem

        name: account.displayName
        indicator.iconSource: "image://theme/graphic-service-nextcloud"
        totalItemCount: root._modelCount
        memberCount: totalItemCount
        userRemovable: eventModel.supportedActions & NextcloudEventModel.DeleteAllEvents

        onRemoveRequested: {
            removeComponent.createObject(root, { "target": root })
        }

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
        anchors.top: headerItem.bottom
        width: parent.width
        height: Screen.height * 1000 // Ensures the view is fully populated without needing to bind height: contentHeight

        interactive: false
        model: boundedModel
    }

    NotificationExpansionButton {
        id: expansionToggle

        y: headerItem.height + listView.contentHeight
        expandable: eventModel.count > _expansionThreshold
                    || eventModel.count > _expansionMaximum

        title: !item._manuallyExpanded
               ? defaultTitle
                //% "Show more in Nextcloud"
               : qsTrId("lipstick-jolla-home-la-show-more-in-nextcloud")

        onClicked: {
            if (!root._manuallyExpanded) {
                var itemPosY = listView.contentHeight + headerItem.height - Theme.paddingLarge
                root._manuallyExpanded = true
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
        maximumCount: root._manuallyExpanded ? root._expansionMaximum : root._expansionThreshold

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
