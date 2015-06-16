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

        property int baseHeight: view.height + addAccountItem.height + image.height + skipButton.height + 2*Theme.paddingLarge
        contentHeight: Math.max(baseHeight, height)

        AccountsListView {
            id: view
            width: root.width
            height: ((count-1) * Theme.itemSizeMedium) + headerItem.height  // count-1 to omit jolla account (we know it has been created at this point)
            interactive: false
            _hideJollaAccount: true
            header: Column {
                width: root.width

                Label {
                    x: Theme.horizontalPageMargin
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
                    x: Theme.horizontalPageMargin
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
                    leftMargin: Theme.horizontalPageMargin
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
            id: image

            anchors {
                top: addAccountItem.bottom
                topMargin: Theme.paddingLarge
                horizontalCenter: parent.horizontalCenter
            }
            visible: !root._hasCreatedAccount
            height: !visible ? 0 : undefined
            source: "image://theme/graphic-startup-addyourcontent"
        }

        Item {
            id: spacer

            height: flickable.contentHeight - flickable.baseHeight

            anchors {
                top: image.bottom
                topMargin: Theme.paddingLarge
                left: parent.left
                right: parent.right
            }
        }

        Button {
            id: skipButton
            anchors {
                top: spacer.bottom
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
