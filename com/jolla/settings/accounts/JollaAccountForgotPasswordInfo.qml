import QtQuick 2.0
import Sailfish.Silica 1.0

Column {
    id: root

    property int animationDuration: 250
    property int animationEasingType: Easing.InOutQuad

    width: parent.width

    state: "visible"
    states: [
        State {
            name: "visible"
            PropertyChanges { target: forgottenPasswordDetails; opacity: 0 }
            PropertyChanges {
                target: root
                height: forgottenPasswordHeading.height
                opacity: 1
                enabled: true
            }
        },
        State {
            name: "expanded"
            PropertyChanges {
                target: root
                height: forgottenPasswordHeading.implicitHeight + forgottenPasswordDetails.implicitHeight + Theme.paddingLarge
            }
            PropertyChanges {
                target: forgottenPasswordDetails
                opacity: 1
            }
        },
        State {
            name: "hidden"
            PropertyChanges { target: forgottenPasswordDetails; opacity: 0 }
            PropertyChanges {
                target: root
                height: 0
                opacity: 0
                enabled: false
            }
        }
    ]

    transitions: [
        Transition {
            from: "*"; to: "expanded"
            reversible: true
            SequentialAnimation {
                NumberAnimation {
                    target: root
                    property: "height"
                    duration: root.animationDuration/2
                    easing.type: root.animationEasingType
                }
                FadeAnimation {
                    duration: root.animationDuration/2
                }
            }
        },
        Transition {
            from: "hidden"; to: "visible"
            reversible: true
            SequentialAnimation {
                NumberAnimation {
                    target: root
                    property: "height"
                    duration: root.animationDuration/2
                }
                FadeAnimation {
                    duration: root.animationDuration/2
                }
            }
        }
    ]

    ClickableTextLabel {
        id: forgottenPasswordHeading
        x: Theme.horizontalPageMargin
        width: parent.width - x*2
        height: implicitHeight + Theme.paddingLarge
        verticalAlignment: Text.AlignVCenter
        wrapMode: Text.Wrap
        font.pixelSize: Theme.fontSizeSmall

        //: Tap to show more information about retrieving a forgotten password (Text surrounded by %1 and %2 is underlined and colored differently)
        //% "%1Forgot your password?%2"
        text: qsTrId("settings_accounts-la-forgot_your_password_link")
                        .arg("<u><font color=\"" + (pressed ? Theme.highlightColor : Theme.primaryColor) + "\">")
                        .arg("</font></u>")
        onClicked: {
            root.state = (root.state == "expanded" ? "visible" : "expanded")
        }
    }

    Label {
        id: forgottenPasswordDetails
        x: Theme.horizontalPageMargin
        width: parent.width - x*2
        wrapMode: Text.Wrap
        font.pixelSize: Theme.fontSizeSmall
        color: Theme.highlightColor
        opacity: 0

        //: Explains how to deal with a forgotten password for the Jolla account
        //% "Please go to account.jolla.com to reset your password. You also need to have access to the email address you provided when creating the account."
        text: qsTrId("settings_accounts-la-forgot_your_password_solution")
    }
}
