/*
 * Copyright (c) 2013 - 2019 Jolla Ltd.
 * Copyright (c) 2019 Open Mobile Platform LLC.
 *
 * License: Proprietary
 */

import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Store 1.0

Dialog {
    id: root

    property StartupApplicationModel applicationModel
    property int selectedAppCount: applicationList.selectionCount

    onAccepted: {
        applicationList.installSelectedApps()
    }

    ApplicationList {
        id: applicationList
    }

    BusyLabel {
        running: !applicationModel.populated
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: header.height + contentColumn.height + Theme.paddingLarge

        VerticalScrollDecorator {}

        WizardDialogHeader {
            id: header
        }

        // alternative header, only displayed while list of apps is still loading
        Label {
            id: headingLabel
            anchors.top: header.bottom
            x: Theme.horizontalPageMargin
            width: parent.width - x*2
            height: implicitHeight + Theme.paddingLarge
            wrapMode: Text.Wrap
            font.pixelSize: Theme.fontSizeExtraLarge
            font.family: Theme.fontFamilyHeading
            color: Theme.highlightColor
            opacity: applicationModel.populated ? 0 : 1
            Behavior on opacity { FadeAnimation {} }

            //: Heading for page that allows user to install Android™ App Support.
            //% "Get Android™ App Support"
            text: qsTrId("startupwizard-he-get_android_app_support")
        }

        Column {
            id: contentColumn
            anchors.top: header.bottom
            width: parent.width
            enabled: applicationModel.count > 0
            opacity: enabled ? 1 : 0
            Behavior on opacity { FadeAnimation {} }

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - x*2
                height: implicitHeight + Theme.paddingLarge
                wrapMode: Text.Wrap
                font.pixelSize: Theme.fontSizeExtraLarge
                font.family: Theme.fontFamilyHeading
                color: Theme.highlightColor

                //: Heading for page that allows user to install Android™ App Support.
                //% "Do you want to use Android™ apps?"
                text: qsTrId("startupwizard-he-do_you_want_to_use_android_apps")
            }

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - x*2
                height: implicitHeight + Theme.paddingLarge
                wrapMode: Text.Wrap
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeExtraSmall
                visible: applicationModel.androidSupportPackageAvailable

                //: Hint to user to install Android™ App Support.
                //% "If you want to use Android apps on the device, select this to install Android App Support."
                text: qsTrId("startupwizard-la-install_android_support")
            }

            Repeater {
                model: applicationModel.androidSupportPackageAvailable ? applicationModel : undefined
                delegate: AndroidApplicationDelegate {
                    visible: applicationModel.isAndroidSupportPackage(model.packageName)
                    onSelectedChanged: {
                        applicationList.updateApplicationSelection(model.packageName, selected)
                    }
                    Connections {
                        target: root
                        onStatusChanged: {
                            if (root.status == PageStatus.Inactive && root.result == DialogResult.Accepted) {
                                beingInstalled = selected
                            }
                        }
                    }
                }
            }

            Item {
                width: 1
                height: Theme.paddingLarge * 2
                visible: applicationModel.androidSupportPackageAvailable
            }

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - x*2
                height: implicitHeight + Theme.paddingLarge
                wrapMode: Text.Wrap
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeExtraSmall

                //: Explains how to install Android apps and stores later on.
                //% "You can install additional stores to your device to find your favorite Android apps like Facebook, Twitter and WhatsApp. For more Android apps and stores, visit the Store app later."
                text: qsTrId("startupwizard-la-install_additional_android_stores")
            }

            Column {
                width: parent.width
                spacing: Theme.paddingSmall

                Repeater {
                    model: applicationModel
                    delegate: AndroidApplicationDelegate {
                        visible: !applicationModel.isAndroidSupportPackage(model.packageName)
                        onSelectedChanged: {
                            applicationList.updateApplicationSelection(model.packageName, selected)
                        }

                        Connections {
                            target: root
                            onStatusChanged: {
                                if (root.status == PageStatus.Inactive && root.result == DialogResult.Accepted) {
                                    beingInstalled = selected
                                }
                            }
                        }
                    }
                }
            }
        }

        ViewPlaceholder {
            // Shown only if no selections are available
            enabled: applicationModel.populated && applicationModel.count == 0
        }
    }
}
