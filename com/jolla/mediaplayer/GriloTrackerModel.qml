/*
 * Copyright (C) 2012-2015 Jolla Ltd.
 *
 * The code in this file is distributed under multiple licenses, and as such,
 * may be used under any one of the following licenses:
 *
 *   - GNU General Public License as published by the Free Software Foundation;
 *     either version 2 of the License (see LICENSE.GPLv2 in the root directory
 *     for full terms), or (at your option) any later version.
 *   - GNU Lesser General Public License as published by the Free Software
 *     Foundation; either version 2.1 of the License (see LICENSE.LGPLv21 in the
 *     root directory for full terms), or (at your option) any later version.
 *   - Alternatively, if you have a commercial license agreement with Jolla Ltd,
 *     you may use the code under the terms of that license instead.
 *
 * You can visit <https://sailfishos.org/legal/> for more information
 */

// -*- qml -*-

import QtQuick 2.0
import Sailfish.Silica 1.0
import org.nemomobile.grilo 0.1

GriloModel {
    id: griloModel

    property string pluginId: "grl-tracker"
    property alias query: querySource.query

    signal finished()

    onPluginIdChanged: griloRegistry.safeLoadPluginById()

    function refresh() {
        querySource.safeRefresh()
    }

    source: GriloQuery {
        id: querySource

        property bool canRefresh: applicationActive || cover.status != Cover.Inactive
        property bool shouldRefresh: true

        source: "grl-tracker-source"
        registry: GriloRegistry {
            id: griloRegistry

            function safeLoadPluginById() {
                if (griloModel.pluginId != "") loadPluginById(griloModel.pluginId)
            }

            Component.onCompleted: safeLoadPluginById()
        }

        function safeRefresh() {
            if (!canRefresh) {
                if (!shouldRefresh) shouldRefresh = true
                return
            }

            if (shouldRefresh) shouldRefresh = false

            if (query && query != "" && available) refresh()
        }

        onQueryChanged: safeRefresh()
        onAvailableChanged: safeRefresh()
        onContentUpdated: safeRefresh()
        onCanRefreshChanged: if (canRefresh && shouldRefresh) safeRefresh()
        Component.onCompleted: finished.connect(griloModel.finished)
    }
}
