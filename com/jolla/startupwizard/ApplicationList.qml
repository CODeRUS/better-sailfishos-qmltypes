/****************************************************************************
**
** Copyright (C) 2013 Jolla Ltd.
** Contact: Petri M. Gerdt <petri.gerdt@jollamobile.com>
**
****************************************************************************/

import QtQuick 2.0
import Sailfish.Silica 1.0

Grid {
    id: root

    property int selectionCount
    property var selectedApplications: []
    property alias model: repeater.model

    // Temporary workaround for showing different localization text
    // if "aliendalvik" is found from store, see JB#19327.
    property bool containsAndroidSupport

    width: parent.width

    function updateApplicationSelection(packageName, selected) {
        var index = selectedApplications.indexOf(packageName);
        if (selected && index < 0) {
            selectedApplications.push(packageName);
            selectionCount++
        } else if (!selected && index > -1) {
            selectedApplications.splice(index, 1);
            selectionCount--
        }
        if (packageName === "aliendalvik") {
            containsAndroidSupport = true
        }
    }

    Repeater {
        id: repeater

        onItemAdded: updateApplicationSelection(item.packageName, item.selected)
        onItemRemoved: updateApplicationSelection(item.packageName, item.selected)

        delegate: BackgroundItem {
            property bool selected: model.preselected
            property string packageName: model.packageName

            width: root.width / 4
            height: icon.height + label.height + 2 * Theme.paddingMedium + Theme.paddingSmall
            highlighted: down || selected
            highlightedColor: Theme.rgba(Theme.highlightBackgroundColor, 0.5)
            onClicked: {
                selected = !selected
                root.updateApplicationSelection(packageName, selected)
            }

            Image {
                id: icon
                anchors {
                    top: parent.top
                    topMargin: Theme.paddingMedium
                    horizontalCenter: parent.horizontalCenter
                }
                height: Theme.iconSizeLauncher
                width: height
                source: model.icon
            }

            Label {
                id: label
                anchors {
                    top: icon.bottom
                    topMargin: Theme.paddingSmall
                    left: parent.left
                    right: parent.right
                }
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: Theme.fontSizeTiny
                elide: Text.ElideRight
                text: model.displayName
                color: highlighted ? Theme.highlightColor : Theme.primaryColor
            }
        }
    }
}
