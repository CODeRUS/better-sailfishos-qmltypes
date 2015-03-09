/****************************************************************************
**
** Copyright (C) 2013 Jolla Ltd.
** Contact: Petri M. Gerdt <petri.gerdt@jollamobile.com>
**
****************************************************************************/

import QtQuick 2.0
import Sailfish.Silica 1.0
import org.nemomobile.dbus 1.0
import Sailfish.Store 1.0
import Sailfish.Accounts 1.0

Dialog {
    id: dialog

    property bool appsAreBeingInstalled

    onAccepted: {
        var tmp = jollaApplicationList.selectedApplications.concat(marketplaceApplicationList.selectedApplications)
        if (tmp.length > 0) {
            appsAreBeingInstalled = true
        }
        for (var i = 0; i < tmp.length; i++) {
            storeClientInterface.call("installPackage", tmp[i])
        }
    }

    onStatusChanged: {
        if (status == PageStatus.Activating) {
            marketplaceApplicationModel.populate(accountManager.getProviderList());
        }
    }

    StartupApplicationModel {
        id: jollaApplicationModel

        category: "jolla"
    }

    StartupApplicationModel {
        id: marketplaceApplicationModel

        category: "marketplace"
    }

    AccountManager {
        id: accountManager

        function getProviderList() {
            var providerList = []
            for (var i = 0; i < accountManager.accountIdentifiers.length; ++i) {
                var account = accountManager.account(accountManager.accountIdentifiers[i])
                if (providerList.indexOf(account.providerName) === -1) {
                    providerList.push(account.providerName)
                }
            }
            return providerList
        }
    }

    DBusInterface {
        id: storeClientInterface
        destination: "com.jolla.jollastore"
        path: "/StoreClient"
        iface: "com.jolla.jollastore"
    }

    SilicaFlickable {
        id: flickable

        anchors.fill: parent
        contentHeight: contentColumn.height

        VerticalScrollDecorator {}

        Column {
            id: contentColumn

            width: flickable.width
            spacing: Theme.paddingLarge

            DialogHeader {
                id: dialogHeader

                property int selectionCount: marketplaceApplicationList.selectionCount
                                             + jollaApplicationList.selectionCount

                acceptText: selectionCount === 0
                         //: Button to skip the current step in the start-up wizard
                         //% "Skip"
                       ? qsTrId("startupwizard-la-skip")
                         //: Number of selected applications, %n will be replaced with a number
                         //% "%n selected"
                       : qsTrId("startupwizard-la-selected", selectionCount)
            }

            Label {
                id: pageHeading
                x: Theme.paddingLarge
                width: parent.width - x*2
                wrapMode: Text.Wrap
                font.pixelSize: Theme.fontSizeExtraLarge
                color: Theme.highlightColor

                //: Heading for page that allows the user to install applications
                //% "Get your apps"
                text: qsTrId("startupwizard-he-applications")
            }

            Label {
                id: pageDescription
                x: Theme.paddingLarge
                width: parent.width - x*2
                wrapMode: Text.Wrap
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeExtraSmall

                //% "Select Jolla apps that you want to install. Selected apps will be downloaded from Jolla store and added to your Jolla"
                text: qsTrId("startupwizard-la-choose_applications")
            }

            ApplicationList {
                id: jollaApplicationList

                model: jollaApplicationModel
            }

            Label {
                x: Theme.paddingLarge
                width: parent.width - x*2
                wrapMode: Text.Wrap
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeExtraSmall
                visible: marketplaceApplicationModel.count > 0

                text: marketplaceApplicationList.containsAndroidSupport
                      //% "We recommend Android support. You can use Android apps on your Jolla and install additional stores to find your favorite Android apps."
                      ? qsTrId("startupwizard-la-android-applications")
                      //% "You can install additional stores to your Jolla and find your favorite Android apps."
                      : qsTrId("startupwizard-la-marketplaces")
            }

            ApplicationList {
                id: marketplaceApplicationList

                model: marketplaceApplicationModel
            }

            Item {
                height: 1
                width: 1
            }
        }

        Column {
            id: col
            y: pageDescription.y + pageDescription.implicitHeight + Theme.itemSizeLarge
            width: parent.width
            visible: jollaApplicationModel.count == 0 && marketplaceApplicationModel.count == 0
            spacing: Theme.paddingLarge

            BusyIndicator {
                id: busyIndicator
                anchors.horizontalCenter: parent.horizontalCenter
                running: parent.visible
                size: BusyIndicatorSize.Large
            }

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width - Theme.padding*2
                wrapMode: Text.WordWrap
                color: Theme.highlightColor
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: Theme.fontSizeSmall

                //: Heading shown above a busy indicator while waiting for a list of apps
                //% "Getting list of applications"
                text: qsTrId("startupwizard-la-getting-application-list")
            }
        }
    }
}
