/*
 * Copyright (c) 2020 Open Mobile Platform LLC.
 *
 * License: Proprietary
 */

import QtQuick 2.0
import Sailfish.Silica 1.0
import org.nemomobile.systemsettings 1.0

Column {
    id: section

    property alias desktopFile: permissions.desktopFile
    property alias showSectionHeader: header.visible

    SectionHeader {
        id: header

        //: Section header for a block of application permissions
        //% "Permissions"
        text: qsTrId("settings-he-permissions")
    }

    Label {
        width: section.width - 2*x
        x: Theme.horizontalPageMargin
        color: Theme.secondaryHighlightColor
        font.pixelSize: Theme.fontSizeSmall
        text: (permissions.count > 0)
            //: Displayed in settings when application has some additional permissions
            //% "This app has permission(s) to access the following in addition to text input, haptic feedback and notifications"
            ? qsTrId("settings-la-sandboxing_disclaimer", permissions.count)
            //: Displayed in settings when application is sandboxed but uses only base set of permissions
            //% "This app has permissions to access text input, haptic feedback and notifications"
            : qsTrId("settings-la-sandboxing_no_permissions")
        wrapMode: Text.Wrap
    }

    Repeater {
        delegate: ListItem {
            id: permissionItem

            property bool expanded

            // Skip Privileged permission
            visible: model.name !== "Privileged"
            contentItem.clip: expanded
            contentHeight: description.implicitHeight + 2*description.y
            width: section.width
            onClicked: openMenu()
            Behavior on contentHeight { NumberAnimation { duration: 100; easing.type: Easing.InOutQuad } }

            Label {
                id: description

                text: model.description
                wrapMode: permissionItem.expanded ? Text.Wrap : Text.NoWrap
                truncationMode: permissionItem.expanded ? TruncationMode.None
                                                        : TruncationMode.Fade
                x: Theme.horizontalPageMargin
                y: Theme.paddingSmall/2
                width: parent.width - 2*x
            }

            menu: Component {
                ContextMenu {
                    onActiveChanged: if (active) permissionItem.expanded = true
                    onClosed: permissionItem.expanded = false

                    hasContent: longDescription.text !== ""

                    Label {
                        id: longDescription

                        text: model.longDescription
                        color: Theme.highlightColor
                        x: Theme.horizontalPageMargin
                        width: parent.width - 2*x
                        topPadding: Theme.paddingMedium
                        bottomPadding: Theme.paddingMedium
                        wrapMode: Text.Wrap
                    }
                }
            }
        }

        model: PermissionsModel { id: permissions }
    }
}
