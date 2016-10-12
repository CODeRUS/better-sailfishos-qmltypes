/****************************************************************************
**
** Copyright (C) 2013 Jolla Ltd.
** Contact: Petri M. Gerdt <petri.gerdt@jollamobile.com>
**
****************************************************************************/

import QtQuick 2.0
import Sailfish.Silica 1.0
import com.jolla.settings 1.0
import Sailfish.Store 1.0
import Sailfish.Lipstick 1.0

Dialog {
    id: root

    property StartupApplicationModel applicationModel
    property int selectedAppCount: applicationList.selectionCount

    onAccepted: {
        applicationList.installSelectedApps()
    }

    property bool skipDialog: status == PageStatus.Active && root.applicationModel.populated
                              && applicationModel.count === 0
    onSkipDialogChanged: if (skipDialog) accept()

    ApplicationList {
        id: applicationList
    }

    ApplicationsGridView {
        id: appGrid

        property real contentOffset: (root.width - (cellWidth * columnCount)) / 2

        minimumDelegateSize: Screen.sizeCategory >= Screen.Large
                             ? Theme.iconSizeLauncher
                             : initialCellWidth
        width: parent.width
        model: applicationModel

        Component.onCompleted: {
            if (Screen.sizeCategory < Screen.Large) {
                minimumCellWidth += Theme.paddingSmall
            }
        }

        header: Column {
            width: root.width

            WizardDialogHeader {
                //: Heading for page that allows the user to install applications
                //% "Select your apps"
                title: qsTrId("startupwizard-he-select_your_apps")
            }

            Label {
                id: introLabel
                x: Theme.horizontalPageMargin
                height: implicitHeight + (Screen.sizeCategory >= Screen.Large ? Theme.paddingLarge*2 : Theme.paddingLarge)
                width: parent.width - x*2
                wrapMode: Text.Wrap
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeExtraSmall

                //% "Selected apps will be downloaded from the Jolla store and installed to your Jolla."
                text: qsTrId("startupwizard-la-selected_apps_will_be_downloaded_and_installed")
            }
        }

        delegate: Item {
            id: appDelegate

            property bool selected: model.preselected
            property bool beingInstalled

            Connections {
                target: root
                onStatusChanged: {
                    if (root.status == PageStatus.Inactive && root.result == DialogResult.Accepted) {
                        beingInstalled = selected
                    }
                }
            }

            width: appGrid.cellWidth
            height: appGrid.cellHeight
            enabled: !beingInstalled

            Rectangle {
                anchors.fill: appDisplay
                color: appDisplay.highlighted || appDelegate.beingInstalled
                       ? Theme.rgba(Theme.highlightBackgroundColor, Theme.highlightBackgroundOpacity)
                       : (appDelegate.selected ? Theme.rgba(Theme.highlightBackgroundColor, 0.1) : "transparent")
                opacity: appDelegate.beingInstalled ? 0.3 : 1
            }

            onSelectedChanged: {
                applicationList.updateApplicationSelection(model.packageName, appDelegate.selected)
            }

            LauncherGridItem {
                id: appDisplay
                anchors {
                    centerIn: parent
                    horizontalCenterOffset: appGrid.contentOffset
                }
                width: Math.min(appGrid.cellWidth, Theme.itemSizeExtraLarge
                            + (Screen.sizeCategory >= Screen.Large ? Theme.paddingSmall * 2 : 0))
                height: Theme.itemSizeExtraLarge + Theme.paddingSmall
                icon: model.icon
                text: model.displayName
                opacity: appDelegate.beingInstalled ? 0.3 : 1

                onClicked: {
                    appDelegate.selected = !appDelegate.selected
                }
            }

            BusyIndicator {
                anchors {
                    centerIn: appDisplay
                    verticalCenterOffset: -Theme.paddingMedium
                }
                running: appDelegate.beingInstalled || appDisplay.iconStatus !== Image.Ready
            }

            Image {
                anchors {
                    top: appDisplay.top
                    right: appDisplay.right
                }
                visible: appDelegate.selected
                source: "image://theme/icon-s-installed" + (appDisplay.highlighted ? "?" + Theme.highlightColor : "")
                opacity: appDelegate.beingInstalled ? 0.3 : 1
            }
        }
    }

    LoadingPlaceholder {
        y: Math.max(root.height/2 - height/2, appGrid.headerItem.height)
        visible: !root.applicationModel.populated
    }

    ViewPlaceholder {
        // Shown only if no selections are available
        enabled: root.applicationModel.populated && root.applicationModel.count == 0
    }
}
