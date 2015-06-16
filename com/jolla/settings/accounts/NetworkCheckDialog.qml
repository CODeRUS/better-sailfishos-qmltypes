import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Accounts 1.0
import com.jolla.settings.accounts 1.0
import org.nemomobile.dbus 1.0

Dialog {
    id: root

    property bool _connectionSelected
    property bool _connectionSelectorClosed
    property bool _shouldAccept
    property bool _shouldReject

    function _showConnSelector() {
        _connectionSelectorClosed = false
        _connectionSelected = false
        connectionSelector.call('openConnection', ["wlan"])
    }

    function _checkStatus() {
        if (status == PageStatus.Active) {
            if (_shouldReject) {
                pageStack.pop()
            } else if (_shouldAccept) {
                canAccept = true
                accept()
            }
        }
    }

    function _tryAccept() {
        _shouldAccept = true
        _shouldReject = false
        _checkStatus()
    }

    function _tryReject() {
        _shouldAccept = false
        _shouldReject = true
        _checkStatus()
    }

    acceptDestinationAction: PageStackAction.Replace
    canAccept: false

    onStatusChanged: {
        if (status == PageStatus.Active) {
            if (accountFactory.haveNetworkConnectivity()) {
                _tryAccept()
            } else if (_shouldAccept || _shouldReject) {
                _checkStatus()
            } else {
                accountFactory.attemptToConnectNetwork()
                openConnSelector.start() // delay in case network connection is available
            }
        }
    }

    on_ShouldAcceptChanged: {
        _checkStatus()
    }

    on_ShouldRejectChanged: {
        _checkStatus()
    }

    onDone: {
        _shouldAccept = false
        _shouldReject = false
    }

    Timer {
        id: openConnSelector
        interval: 100
        onTriggered: {
            if (status == PageStatus.Active && !accountFactory.haveNetworkConnectivity()) {
                _showConnSelector()
            }
        }
    }

    BusyIndicator {
        id: busyIndicator
        anchors.centerIn: parent
        size: BusyIndicatorSize.Large
        running: root._connectionSelected
    }

    Column {
        id: retryText
        x: Theme.horizontalPageMargin
        y: Theme.itemSizeLarge
        width: parent.width - x*2
        spacing: Theme.paddingLarge
        visible: root._connectionSelectorClosed && !root._connectionSelected

        Label {
            width: parent.width
            font.pixelSize: Theme.fontSizeExtraLarge
            color: Theme.highlightColor
            wrapMode: Text.Wrap
            //: Not connected to the internet
            //% "Not connected"
            text: qsTrId("settings_accounts-la-not_connected")
        }

        Label {
            width: parent.width
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.highlightColor
            wrapMode: Text.Wrap
            //: The user did not select a network connection
            //% "You must select an internet connection to continue."
            text: qsTrId("settings_accounts-la-must_select_conn")
        }
    }

    Button {
        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: parent.bottom
            bottomMargin: Theme.paddingLarge
        }
        visible: retryText.visible
        //% "Retry"
        text: qsTrId("settings_accounts-bt-retry")

        onClicked: {
            root._showConnSelector()
        }
    }

    DBusInterface {
        id: connectionSelector
        destination: "com.jolla.lipstick.ConnectionSelector"
        path: "/"
        iface: "com.jolla.lipstick.ConnectionSelectorIf"
        signalsEnabled: true

        function connectionSelectorClosed(connectionSelected) {
            root._connectionSelectorClosed = true
            root._connectionSelected = connectionSelected
            if (connectionSelected) {
                root._tryAccept()
            }
        }
    }

    SequentialAnimation {
        id: delayedAcceptAnim
        PauseAnimation { duration: 400 }
        ScriptAction { script: root._tryAccept() }
    }

    AccountFactory {
        id: accountFactory

        onNetworkConnectivityEstablished: {
            if (retryText.visible) {
                // system automatically connected after the connection selector was closed;
                // avoid accepting the dialog immediately so that it looks less jumpy
                busyIndicator.running = true
                retryText.visible = false
                delayedAcceptAnim.start()
            } else {
                root._tryAccept()
            }
        }
    }
}
