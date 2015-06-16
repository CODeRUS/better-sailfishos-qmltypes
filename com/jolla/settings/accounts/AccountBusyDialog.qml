import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Silica.theme 1.0
import com.jolla.settings.accounts 1.0

// xxxxxx for legacy versions of email and active sync plugins xxxxxx

Dialog {
    id: root

    property string successDialogHeader

    //: Skip the account creation process as there was an error.
    //% "Skip"
    property string errorDialogHeader: qsTrId("components_accounts-he-skip")

    property string successHeading
    property string successDescription

    //: Heading displayed when an account cannot be created.
    //% "Oops, something went wrong"
    property string errorHeading: qsTrId("components_accounts-he-account_creation_error")

    //: Description displayed when an account cannot be created.
    //% "Go back to try again or skip now and add this account later."
    property string errorDescription: qsTrId("components_accounts-la-account_creation_error")

    property alias progressStatusText: statusLabel.text
    property int minimumBusyDuration: 1500

    property int _lastErrorCode
    property string _lastErrorString

    property bool becameTopPage

    signal accountTaskFinished(bool success)
    signal _resetState()

    function stopBusyIndicator(errorCode, information) {

        // Shim for backward compatibility only.
        // The previous API was stopBusyIndicator(bool success, string information)
        if (typeof(errorCode) == 'boolean') {
            if (errorCode == false) {
                errorCode = AccountFactory.UnknownError
            } else {
                errorCode = AccountFactory.NoError
            }
        }
        // End of backward compatibility shim.

        if (minimumBusyDurationTimer.running) {
            _lastErrorCode = errorCode
            _lastErrorString = information
            minimumBusyDurationTimer.triggered.connect(_delayedStopBusyIndicator)
            return
        }
        backNavigation = true
        if (errorCode == AccountFactory.NoError) {
            header.acceptText = successDialogHeader
            headingLabel.text = successHeading
            descriptionLabel.text = successDescription
        } else {
            header.acceptText = errorDialogHeader
            headingLabel.text = errorHeading
            descriptionLabel.text = errorDescription

            if (errorCode == AccountFactory.UnknownError
                    || errorCode == AccountFactory.InternalError) {
                informationLabel.text = "" // the error message won't be human-readable
            } else {
                informationLabel.text = information // the error message should be human readable
            }
        }
        busyIndicator.running = false
        infoColumn.opacity = 1
        accountTaskFinished(errorCode == AccountFactory.NoError)
    }

    function _delayedStopBusyIndicator() {
        minimumBusyDurationTimer.triggered.disconnect(_delayedStopBusyIndicator)
        stopBusyIndicator(_lastErrorCode, _lastErrorString)
    }

    on_ResetState: {
        becameTopPage = false
        minimumBusyDurationTimer.triggered.disconnect(_delayedStopBusyIndicator)
        busyIndicator.running = true
        infoColumn.opacity = 0
        header.title = ""
        headingLabel.text = ""
        descriptionLabel.text = ""
        informationLabel.text = ""
    }

    acceptDestinationAction: PageStackAction.Replace
    backNavigation: (_navigation == PageNavigation.Forward) // prevent jump on animation
    canAccept: false

    Connections {
        target: pageStack
        onCurrentPageChanged: {
            if (!root.becameTopPage && root === pageStack.currentPage) {
                root.becameTopPage = true
                minimumBusyDurationTimer.start()
            }
        }
    }

    DialogHeader {
        id: header
        opacity: root.canAccept ? 1 : 0

        Behavior on opacity {
            enabled: root.minimumBusyDuration > 0
            FadeAnimation {}
        }
    }

    Column {
        anchors.centerIn: parent
        spacing: Theme.paddingLarge
        opacity: busyIndicator.opacity

        Label {
            id: statusLabel
            width: root.width - Theme.horizontalPageMargin*2
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
            color: Theme.highlightColor
        }

        BusyIndicator {
            id: busyIndicator
            anchors.horizontalCenter: parent.horizontalCenter
            size: BusyIndicatorSize.Large
            running: true
        }
    }

    Timer {
        id: minimumBusyDurationTimer
        interval: root.minimumBusyDuration
    }

    Column {
        id: infoColumn

        anchors.top: header.bottom
        x: Theme.horizontalPageMargin
        width: parent.width - x*2
        spacing: Theme.paddingLarge
        opacity: 0

        Behavior on opacity {
            enabled: root.minimumBusyDuration > 0
            FadeAnimation {}
        }

        Label {
            id: headingLabel
            width: parent.width
            wrapMode: Text.Wrap
            font.pixelSize: Theme.fontSizeExtraLarge
            color: Theme.highlightColor
        }

        Label {
            id: informationLabel
            visible: informationLabel.text !== ""
            width: parent.width
            wrapMode: Text.Wrap
            font.pixelSize: Theme.fontSizeExtraSmall
            color: Theme.highlightColor
        }

        Label {
            id: descriptionLabel
            width: parent.width
            wrapMode: Text.Wrap
            font.pixelSize: Theme.fontSizeExtraSmall
            color: Theme.highlightColor
        }
    }
}
