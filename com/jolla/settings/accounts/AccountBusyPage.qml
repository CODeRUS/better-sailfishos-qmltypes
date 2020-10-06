import QtQuick 2.0
import Sailfish.Silica 1.0

// Displays a busy spinner while some task is in progress. Can also display some information
// with an optional button when the task is finished.
//
// In the "busy" state (the default), this shows a busy spinner with a caption.
// In the "info" state, this shows a heading and two labels, and an optional button.
//      The button is shown in this state if infoButtonText is set, and clicking it emits
//      infoButtonClicked().

Page {
    id: root

    state: "busy"   // set to "info" or "busy"

    // these are shown only in 'info' state:
    property string infoHeading: errorHeadingText
    property string infoDescription: accountCreationErrorText
    property string infoExtraDescription
    property string infoButtonText

    // these are shown only in 'busy' state:
    property string busyDescription: creatingAccountText

    signal infoButtonClicked()


    //------ informational text provided for convenience:

    //: Generic heading displayed when an account cannot be created or updated.
    //% "Account error"
    property string errorHeadingText: qsTrId("components_accounts-he-account_error")

    //% "The account could not be created."
    property string accountCreationErrorText: qsTrId("components_accounts-he-cannot_create_account")

    //% "The account could not be updated."
    property string accountUpdateErrorText: qsTrId("components_accounts-he-cannot_update_account")

    //: Description displayed when an account cannot be created.
    //% "Go back to try again or skip now and add this account later."
    property string retryOrSkipOptionText: qsTrId("components_accounts-la-account_creation_error")

    //: Skip the creation of this account
    //% "Skip"
    property string skipButtonText: qsTrId("components_accounts-bt-skip")

    //: Notifies user that the account is currently being created.
    //% "Creating account..."
    property string creatingAccountText: qsTrId("components_accounts-la-creating_account")

    //: Notifies the device is in the process of signing into the account
    //% "Signing in..."
    property string signingInText: qsTrId("components_accounts-la-signing_into_account")

    //: Notifies user that the updated account credentials are currently being saved
    //% "Saving credentials..."
    property string updatingAccountText: qsTrId("components_accounts-la-updating_account_credentials")

    //------ end informational text


    backNavigation: state == "info"

    states: [
        State {
            name: "busy"
            PropertyChanges { target: busyLabel; running: true }
            PropertyChanges { target: infoColumn; opacity: 0 }
            PropertyChanges { target: infoButton; enabled: false }
        },
        State {
            name: "info"
            PropertyChanges { target: busyLabel; running: false }
            PropertyChanges { target: infoColumn; opacity: 1 }
            PropertyChanges { target: infoButton; enabled: infoButton.text.length > 0 }
        }
    ]


    BusyLabel {
        id: busyLabel
        text: root.busyDescription
    }

    Column {
        id: infoColumn
        anchors {
            top: parent.top
            topMargin: Theme.itemSizeLarge
            left: parent.left
            leftMargin: Theme.horizontalPageMargin
            right: parent.right
            rightMargin: Theme.horizontalPageMargin
        }
        spacing: Theme.paddingLarge
        opacity: 0

        Behavior on opacity { FadeAnimation {} }

        Label {
            width: parent.width
            visible: text.length > 0
            wrapMode: Text.Wrap
            font.pixelSize: Theme.fontSizeExtraLarge
            color: Theme.highlightColor
            text: root.infoHeading
        }

        Label {
            width: parent.width
            visible: text.length > 0
            wrapMode: Text.Wrap
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.highlightColor
            text: root.infoDescription
        }

        Label {
            width: parent.width
            visible: text.length > 0
            wrapMode: Text.Wrap
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.highlightColor
            text: root.infoExtraDescription
        }
    }

    Button {
        id: infoButton
        anchors {
            bottom: parent.bottom
            bottomMargin: Theme.paddingLarge
            horizontalCenter: parent.horizontalCenter
        }
        enabled: false
        opacity: enabled ? 1 : 0
        text: root.infoButtonText

        onClicked: root.infoButtonClicked()

        Behavior on opacity { FadeAnimation {} }
    }
}
