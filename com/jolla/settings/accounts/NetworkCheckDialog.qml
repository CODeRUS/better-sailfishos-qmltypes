/*
 * Copyright (c) 2013 - 2019 Jolla Ltd.
 * Copyright (c) 2020 Open Mobile Platform LLC.
 *
 * License: Proprietary
 */

import QtQuick 2.6
import Sailfish.Silica 1.0
import Sailfish.Accounts 1.0
import Nemo.DBus 2.0
import Nemo.Connectivity 1.0
import com.jolla.settings.accounts 1.0

Dialog {
    id: root

    property alias headingText: headingLabel.text
    property alias bodyText: bodyLabel.text
    property alias skipText: skipLabel.text
    property alias skipPressed: skipLabel.pressed

    signal skipClicked()

    property bool _shouldAccept
    readonly property bool _applicationActive: Qt.application.active

    function _checkStatus() {
        if (status === PageStatus.Active) {
            if (_shouldAccept) {
                forwardNavigation = true
                canAccept = true
                accept()
            }
        }
    }

    function _tryAccept() {
        _shouldAccept = true
        _checkStatus()
    }

    acceptDestinationAction: PageStackAction.Replace

    onStatusChanged: {
        if (status === PageStatus.Active) {
            canAccept = false
            forwardNavigation = false
            connectionHelper.attemptToConnectNetwork()
        }
    }

    on_ApplicationActiveChanged: {
        if (_applicationActive && status === PageStatus.Active) {
            if (connectionHelper.online) {
                _tryAccept()
            } else if (!connectionHelper.selectorVisible) {
                connectionHelper.attemptToConnectNetwork()
            }
        }
    }

    onDone: {
        _shouldAccept = false
    }

    ConnectionHelper {
        id: connectionHelper

        onOnlineChanged: {
            if (online && root == pageStack.currentPage) {
                root._tryAccept()
            }
        }
    }

    // The dialog may be visible briefly after the connection dialog is closed and
    // before the dialog is auto-accepted, so show a busy indicator as a placeholder.
    PageBusyIndicator {
        running: connectionHelper.status == ConnectionHelper.Connecting
                || (connectionHelper.online && !connectionHelper.selectorVisible)
    }

    Column {
        id: retryText

        property bool display: root.status === PageStatus.Active
                                && !connectionHelper.online
                                && !connectionHelper.selectorVisible
                                && connectionHelper.status != ConnectionHelper.Connecting

        width: parent.width

        opacity: display ? 1.0 : 0
        Behavior on opacity { FadeAnimation {} }

        // show a header to be consistent with other dialogs, but do not show
        // the accept/cancel navigation
        DialogHeader {
            cancelText: ""
            acceptText: ""
        }

        Label {
            id: headingLabel
            x: Theme.horizontalPageMargin
            width: parent.width - x*2
            height: implicitHeight + Theme.paddingLarge
            font.pixelSize: Theme.fontSizeExtraLarge
            color: Theme.highlightColor
            wrapMode: Text.Wrap
            //: Not connected to the internet
            //% "Not connected"
            text: qsTrId("settings_accounts-la-not_connected")
        }

        Label {
            id: bodyLabel
            x: Theme.horizontalPageMargin
            width: parent.width - x*2
            height: implicitHeight + Theme.paddingLarge*2
            font.pixelSize: Theme.fontSizeExtraSmall
            color: Theme.highlightColor
            wrapMode: Text.Wrap
            //: The user did not select a network connection
            //% "You must select an internet connection to continue."
            text: qsTrId("settings_accounts-la-must_select_conn")
        }

        Button {
            id: retryButton
            anchors.horizontalCenter: parent.horizontalCenter
            //: Display the dialog to set up the internet connection
            //% "Connect"
            text: qsTrId("settings_accounts-bt-connect")

            onClicked: connectionHelper.attemptToConnectNetwork()
        }
    }

    ClickableTextLabel {
        id: skipLabel
        anchors {
            left: parent.left
            leftMargin: Theme.horizontalPageMargin
            bottom: parent.bottom
            bottomMargin: Theme.paddingLarge
            right: parent.right
            rightMargin: Theme.horizontalPageMargin
        }
        verticalAlignment: Text.AlignBottom
        font.pixelSize: Theme.fontSizeSmall
        visible: text != ""

        // even when other explanatory text is hidden, show the skip label but dim it to still indicate skipping is possible
        opacity: retryText.display ? 1.0 : Theme.highlightBackgroundOpacity
        Behavior on opacity { FadeAnimation {} }

        onClicked: {
            root.forwardNavigation = true
            root.skipClicked()
        }
    }
}
