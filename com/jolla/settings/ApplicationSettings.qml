/*
 * Copyright (c) 2020 Open Mobile Platform LLC.
 *
 * License: Proprietary
 */

import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: page

    property alias applicationName: header.title
    property string _desktopFile
    default property alias settings: column.data

    SilicaFlickable {
        id: flickable
        anchors.fill: parent
        contentHeight: {
            if (pushUpMenu === null) {
                return contentItem.childrenRect.height + permissionsSection.height - (pullDownMenu !== null ? pullDownMenu.height : 0)
            } else {
                // PushUpMenu doesn't work with the calculation above. This calculation
                // works but then PermissionSection doesn't work with ViewPlaceholder.
                return column.height + permissionsSection.height
            }
        }
        Component.onCompleted: {
            if (pushUpMenu !== null) {
                // A warning related to the comment in contentHeight
                console.warn("ApplicationSettings can't currently support PushUpMenu, please consider not using it")
            }
        }

        Column {
            id: column
            width: parent.width

            PageHeader {
                id: header
            }
        }

        VerticalScrollDecorator {}
    }

    Loader {
        id: permissionsSection
        active: _desktopFile !== ""
        // Hack to make ContextMenu work well inside this.
        // We can't parent this to flickable.contentItem as it should be
        // because that would create a binding loop but parenting to
        // flickable itself works just fine for this limited use case.
        parent: flickable
        sourceComponent: Component {
            PermissionsSection {
                desktopFile: page._desktopFile
                showSectionHeader: column.children.length > 1
                width: page.width
            }
        }
        height: implicitHeight + Theme.paddingLarge
        y: flickable.contentHeight - height - flickable.contentY
    }
}
