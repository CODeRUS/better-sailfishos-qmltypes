import QtQuick 2.0
import Sailfish.Silica 1.0

Dialog {
    id: root

    property bool canSkip

    signal accountCreationRequested()
    signal signInRequested()
    signal skipRequested()

    // Anchor the skipLink at the bottom of the screen or below the image depending on
    // the screen space available.
    function _positionSkipLink() {
        if (!skipLink.visible) {
            return
        }
        var fullContentHeight = contentColumn.y + contentColumn.height + skipLink.height + Theme.paddingLarge*2
        skipLink.anchors.topMargin = fullContentHeight < mainFlickable.height
                ? (mainFlickable.height - fullContentHeight + Theme.paddingLarge)
                : Theme.paddingLarge
    }

    forwardNavigation: false

    SilicaFlickable {
        id: mainFlickable
        anchors {
            fill: parent
            topMargin: Theme.itemSizeLarge
        }
        contentHeight: skipLink.visible
                       ? skipLink.y + skipLink.height + Theme.paddingLarge
                       : contentColumn.height

        Component.onCompleted: {
            root._positionSkipLink()
        }

        VerticalScrollDecorator {}

        Column {
            id: contentColumn
            anchors.top: parent.top
            width: parent.width
            spacing: Theme.paddingLarge

            onHeightChanged: {
                root._positionSkipLink()
            }

            Label {
                x: Theme.paddingLarge
                width: parent.width - x*2
                wrapMode: Text.WordWrap
                font {
                    family: Theme.fontFamilyHeading
                    pixelSize: Theme.fontSizeExtraLarge
                }
                color: Theme.highlightColor

                //: Heading for page that allows sign-up for a Jolla account
                //% "Get the full Jolla experience with a Jolla account"
                text: qsTrId("settings_accounts-he-get_jolla_experience_with_jolla_account")
            }

            Label {
                x: Theme.paddingLarge
                width: parent.width - x*2
                wrapMode: Text.WordWrap
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.highlightColor

                //: Description of what a Jolla account offers.
                //% "You'll receive Sailfish OS updates, get access to essential Jolla apps, easily fetch your feeds and other content, enable app service features, and more."
                text: qsTrId("settings_accounts-la-jolla_account_features_description")
            }

            Item {
                width: parent.width
                height: createAccountButton.height

                Button {
                    id: createAccountButton
                    anchors {
                        left: parent.left
                        leftMargin: Theme.paddingLarge
                    }
                    //: Button label for creating a Jolla account
                    //% "Create account"
                    text: qsTrId("settings_accounts-bt-create_account")
                    onClicked: {
                        root.accountCreationRequested()
                    }
                }
                Button {
                    anchors {
                        right: parent.right
                        rightMargin: Theme.paddingLarge
                    }
                    //: Button label for creating a Jolla account
                    //% "Sign in"
                    text: qsTrId("settings_accounts-bt-sign_in")
                    onClicked: {
                        root.signInRequested()
                    }
                }
            }

            Image {
                id: prettyImage
                anchors.horizontalCenter: parent.horizontalCenter
                source: "image://theme/graphic-store-jolla-apps"
            }
        }

        ClickableTextLabel {
            id: skipLink
            anchors {
                horizontalCenter: parent.horizontalCenter
                top: contentColumn.bottom
            }

            horizontalAlignment: Text.AlignHCenter
            visible: root.canSkip
            font.pixelSize: Theme.fontSizeSmall
            color: pressed ? Theme.highlightColor : Theme.secondaryColor

            //: Alternative option if user doesn't want to create or sign into a Jolla account at the moment. (Text surrounded by %1 and %2 is underlined and colored differently)
            //% "Or, %1skip%2 Jolla account setup for now"
            text: qsTrId("settings_accounts-la-sign_in_skip_jolla_account_link")
                            .arg("<u><font color=\"" + Theme.primaryColor + "\">")
                            .arg("</font></u>")
            onClicked: {
                pageStack.push(skipConfirmationComponent)
            }
        }
    }

    Component {
        id: skipConfirmationComponent
        Page {
            // Anchor the buttons section at the bottom of the screen or below the image depending on
            // the screen space available.
            function _positionBottomSection() {
                var fullContentHeight = skipConfirmationContent.y + skipConfirmationContent.height + skipConfirmationButtons.height + Theme.paddingLarge*2
                skipConfirmationButtons.anchors.topMargin = fullContentHeight < skipFlick.height
                        ? (skipFlick.height - fullContentHeight + Theme.paddingLarge)
                        : Theme.paddingLarge
            }

            Component.onCompleted: {
                _positionBottomSection()
            }

            SilicaFlickable {
                id: skipFlick
                anchors.fill: parent
                contentHeight: skipConfirmationButtons.y + skipConfirmationButtons.height + Theme.paddingLarge

                Column {
                    id: skipConfirmationContent
                    y: Theme.itemSizeLarge
                    width: parent.width
                    spacing: Theme.paddingLarge

                    onHeightChanged: {
                        _positionBottomSection()
                    }

                    Label {
                        x: Theme.paddingLarge
                        width: parent.width - x*2
                        wrapMode: Text.WordWrap
                        font {
                            family: Theme.fontFamilyHeading
                            pixelSize: Theme.fontSizeExtraLarge
                        }
                        color: Theme.highlightColor
                        //: Heading for page where user can confirm whether to really skip Jolla account setup
                        //% "Are you sure you want to skip?"
                        text: qsTrId("settings_accounts-la-skip_confirmation")
                    }

                    Label {
                        x: Theme.paddingLarge
                        width: parent.width - x*2
                        wrapMode: Text.WordWrap
                        color: Theme.highlightColor
                        //: Description of what user will miss if the option to set up a Jolla account is missed
                        //% "Without a Jolla account, you'll only get basic phone functionality. You'll also miss out on OS updates and you won't be able to access the Jolla store."
                        text: qsTrId("settings_accounts-la-without_jolla_account")
                    }

                    Image {
                        source: "image://theme/graphic-startup-skipping"
                    }
                }

                Item {
                    id: skipConfirmationButtons
                    anchors.top: skipConfirmationContent.bottom
                    width: parent.width
                    height: noButton.height

                    Button {
                        id: noButton
                        anchors {
                            left: parent.left
                            leftMargin: Theme.paddingLarge
                        }
                        //: Button label to go back to previous page
                        //% "Go back"
                        text: qsTrId("settings_accounts-bt-go_back")
                        onClicked: {
                            pageStack.pop()
                        }
                    }
                    Button {
                        anchors {
                            right: parent.right
                            rightMargin: Theme.paddingLarge
                        }
                        //: Button label to go back to skip setting up a Jolla account, and do it later instead
                        //% "Skip"
                        text: qsTrId("settings_accounts-bt-skip")
                        onClicked: {
                            root.skipRequested()
                        }
                    }
                }
            }
        }
    }
}
