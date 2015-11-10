/****************************************************************************
 **
 ** Copyright (C) 2015 Jolla Ltd.
 ** Contact: Matt Vogt <matt.vogt@jollamobile.com>
 **
 ****************************************************************************/

import QtQuick 2.0
import QtQml.Models 2.1

// Use a DelegateModel to only show the first N items from a source model
DelegateModel {
    id: root

    property int maximumCount
    property bool updating

    onMaximumCountChanged: allItemsGroup.update()

    items.includeByDefault: maximumCount > 0 ? false : true

    groups: DelegateModelGroup {
        id: allItemsGroup

        function update() {
            _delayedUpdate.stop()
            root.updating = true

            // Add any items that are in the displayed count but not yet in the set
            var remainder = Math.min(count, root.maximumCount)
            if (remainder) {
                addGroups(0, remainder, ["items"])
            }
            // Remove any items in the displayed set that are above the displayed count
            var excess = count - root.maximumCount
            if (excess > 0) {
                removeGroups(root.maximumCount, excess, ["items"])
            }

            root.updating = false
        }

        name: "allItems"
        includeByDefault: root.maximumCount > 0 ? true : false
        onChanged: _delayedUpdate.restart()
    }

    property Timer _delayedUpdate: Timer {
        interval: 0
        onTriggered: allItemsGroup.update()
    }
}
