/****************************************************************************
**
** Copyright (C) 2013 Jolla Ltd.
** Contact: Bea Lam <bea.lam@jollamobile.com>
**
****************************************************************************/

import QtQuick 2.0
import QtQml.Models 2.1
import Sailfish.Silica 1.0
import org.nemomobile.dbus 1.0
import Sailfish.Store 1.0

Dialog {
    id: root

    property StartupApplicationModel applicationModel
    property int selectedAppCount: applicationList.selectionCount

    property string _trademark: "&#8482;"
    property bool _androidSupportPackageAvailable

    function _isAndroidSupportPackage(packageName) {
        return packageName == "aliendalvik"
    }

    onAccepted: {
        applicationList.installSelectedApps()
    }

    // Android stores have momentarily been hidden JB#23623, skip the dialog
    // to avoid empty page if Android support package is not available
    property bool skipDialog: status == PageStatus.Active && root.applicationModel.populated
                              && !_androidSupportPackageAvailable
    onSkipDialogChanged: if (skipDialog) accept()

    DelegateModel {
        model: root.applicationModel
        delegate: QtObject {}
        onCountChanged: {
            var androidSupportPackageAvailable = false
            for (var i = 0; i < items.count; ++i) {
                if (root._isAndroidSupportPackage(items.get(i).model.packageName)) {
                    androidSupportPackageAvailable = true
                    break
                }
            }
            root._androidSupportPackageAvailable = androidSupportPackageAvailable
        }
    }

    ApplicationList {
        id: applicationList
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
            textFormat: Text.RichText // to render "TM" symbol
            opacity: root.applicationModel.populated ? 0 : 1
            Behavior on opacity { FadeAnimation {} }

            //: Heading for page that allows user to install Android app support. "%1" = the "TM" trademark symbol.
            //% "Get Android%1 app support"
            text: qsTrId("startupwizard-he-get_android_app_support").arg(_trademark)
        }

        LoadingPlaceholder {
            y: root.height/2 - height/2
            visible: !root.applicationModel.populated
        }

        Column {
            id: contentColumn
            anchors.top: header.bottom
            width: parent.width
            enabled: root.applicationModel.count > 0
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
                textFormat: Text.RichText // to render "TM" symbol

                //: Heading for page that allows user to install Android app support. "%1" = the "TM" trademark symbol.
                //% "Do you want to use Android%1 apps?"
                text: qsTrId("startupwizard-he-do_you_want_to_use_android_apps").arg(_trademark)
            }

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - x*2
                height: implicitHeight + Theme.paddingLarge
                wrapMode: Text.Wrap
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeExtraSmall
                textFormat: Text.RichText // to render "TM" symbol
                visible: _androidSupportPackageAvailable

                //: Hint to user to install Android support. "%1" = the "TM" trademark symbol.
                //% "If you want to use Android%1 apps in Jolla, select this to install Android%1 support."
                text: qsTrId("startupwizard-la-install_android_support").arg(_trademark)
            }

            Repeater {
                visible: _androidSupportPackageAvailable
                model: _androidSupportPackageAvailable ? root.applicationModel : undefined
                delegate: AndroidApplicationDelegate {
                    visible: _isAndroidSupportPackage(model.packageName)
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
                visible: _androidSupportPackageAvailable
            }

            /*
              Hide Android stores until installation issue JB#23623 is fixed

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - x*2
                height: implicitHeight + Theme.paddingLarge
                wrapMode: Text.Wrap
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeExtraSmall
                textFormat: Text.RichText // to render "TM" symbol

                //: Explains how to install Android apps and stores later on. "%1" = the "TM" trademark symbol.
                //% "You can install additional stores to your Jolla to find your favorite Android%1 apps like Facebook, Twitter and WhatsApp. For more Android%1 apps and stores, visit the Jolla Store later with the Store app."
                text: qsTrId("startupwizard-la-install_additional_android_stores").arg(_trademark)
            }

            Column {
                width: parent.width
                spacing: Theme.paddingSmall

                Repeater {
                    model: root.applicationModel
                    delegate: AndroidApplicationDelegate {
                        visible: !_isAndroidSupportPackage(model.packageName)
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
            */
        }

        ViewPlaceholder {
            // Shown only if no selections are available
            enabled: root.applicationModel.populated && root.applicationModel.count == 0
        }
    }
}
