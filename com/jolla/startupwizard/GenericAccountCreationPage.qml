import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Accounts 1.0
import com.jolla.settings.accounts 1.0

Page {
    id: root

    property bool _hasCreatedAccount

    signal skipped
    signal done

    Flickable {
        id: flickable
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            topMargin: Theme.itemSizeLarge
            bottom: parent.bottom
        }
        contentHeight: skipButton.y + skipButton.height + Theme.paddingLarge

        // Anchor the buttons section at the bottom of the screen or below the image depending on
        // the screen space available.
        function _positionBottomSection() {
            var fullContentHeight = view.y + view.height + addAccountItem.height + skipButton.height + Theme.paddingLarge*2
            skipButton.anchors.topMargin = fullContentHeight < flickable.height
                    ? (flickable.height - fullContentHeight + Theme.paddingLarge)
                    : Theme.paddingLarge
        }

        Component.onCompleted: {
            _positionBottomSection()
        }

        AccountsListView {
            id: view
            width: root.width
            height: ((count-1) * Theme.itemSizeMedium) + headerItem.height  // count-1 to omit jolla account (we know it has been created at this point)
            interactive: false
            _hideJollaAccount: true
            onHeightChanged: {
                flickable._positionBottomSection()
            }
            header: Column {
                width: root.width

                Label {
                    x: Theme.paddingLarge
                    width: parent.width - x*2
                    height: implicitHeight + Theme.paddingLarge
                    wrapMode: Text.WordWrap
                    font.pixelSize: Theme.fontSizeExtraLarge
                    color: Theme.highlightColor

                    //: Heading for page that allows user to select Facebook, Twitter services etc. to sign in and load their content onto the device
                    //% "Get your content"
                    text: qsTrId("startupwizard-he-get_your_content")
                }
                Label {
                    x: Theme.paddingLarge
                    width: parent.width - x*2
                    height: implicitHeight + Theme.paddingLarge
                    wrapMode: Text.WordWrap
                    font.pixelSize: Theme.fontSizeExtraSmall
                    color: Theme.highlightColor

                    //: Description for page that allows user to select Facebook, Twitter services etc. to sign in and load their content onto the device
                    //% "Choose the services you want to use, or skip now and add these later from Settings | Accounts"
                    text: qsTrId("startupwizard-la-get_your_content")
                }
            }
        }

        ListItem {
            id: addAccountItem
            anchors.top: view.bottom
            contentHeight: Theme.itemSizeMedium
            Image {
                id: addAccountIcon
                anchors {
                    verticalCenter: parent.verticalCenter
                    left: parent.left
                    leftMargin: Theme.paddingLarge
                }
                source: "image://theme/icon-m-add"
            }
            Label {
                anchors {
                    left: addAccountIcon.right
                    leftMargin: Theme.paddingLarge
                    verticalCenter: addAccountIcon.verticalCenter
                    right: parent.right
                }
                color: addAccountItem.highlighted ? Theme.highlightColor : Theme.primaryColor
                //% "Add account"
                text: qsTrId("startupwizard-la-add_account")
            }
            onClicked: {
                genericAccountCreator.startAccountCreation()
            }
        }

        Image {
            anchors {
                top: addAccountItem.bottom
                topMargin: Theme.paddingLarge
                horizontalCenter: parent.horizontalCenter
            }
            visible: !root._hasCreatedAccount
            source: "image://theme/graphic-startup-addyourcontent"
        }

        Button {
            id: skipButton
            anchors {
                top: addAccountItem.bottom
                horizontalCenter: parent.horizontalCenter
            }
            text: root._hasCreatedAccount
                    //: Click when desired accounts have been created and ready to proceed to next step
                    //% "Done"
                  ? qsTrId("startupwizard-la-done")
                    //: Button to skip the current step in the start-up wizard
                    //% "Skip"
                  : qsTrId("startupwizard-la-skip")

            onClicked: {
                if (root._hasCreatedAccount) {
                    root.done()
                } else {
                    root.skipped()
                }
            }
        }
    }

    AccountCreationManager {
        id: genericAccountCreator
        endDestination: root
        endDestinationAction: PageStackAction.Pop

        onAccountCreated: {
            flickable.contentY = 0
            root._hasCreatedAccount = true
        }
    }
}
