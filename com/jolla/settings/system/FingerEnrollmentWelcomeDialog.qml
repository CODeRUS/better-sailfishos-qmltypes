import QtQuick 2.2
import Sailfish.Silica 1.0
import com.jolla.settings.system 1.0
import org.nemomobile.devicelock 1.0

FingerEnrollmentPage {
    id: page

    property bool canSkip

    acceptDestination: Qt.resolvedUrl("FingerEnrollmentDialog.qml")
    acceptDestinationAction: canSkip ? PageStackAction.Push : PageStackAction.Replace

    //% "Set up the fingerprint sensor"
    instruction: qsTrId("settings_devicelock-la-setup_fingerprint")

    //% "Your fingerprint can be used for unlocking the device"
    explanation: qsTrId("settings_devicelock-la-setup_fingerprint_explanation")

    Label {
        visible: page.canSkip
        color: skipMouseArea.pressed ? Theme.highlightColor : Theme.primaryColor

        anchors {
             bottom: parent.bottom
             left: parent.left
             margins: Theme.horizontalPageMargin
        }

        //% "Skip"
        text: qsTrId("settings_devicelock-la-skip")

        MouseArea {
            id: skipMouseArea

            anchors.fill: parent
            onClicked: {
                if (page.canSkip) {
                    // The page is part of a larger wizard, cancelling a step within the
                    // enrollment progress should return to this page and allow the option
                    // to skip or restart.
                    pageStack.push(
                                Qt.resolvedUrl("FingerEnrollmentSkipPage.qml"),
                                page.acceptDestinationProperties)
                } else {
                    // The page is the start of explicit request to enroll a finger.  Cancelling
                    // a step should exit the wizard.
                    page.goTo(Qt.resolvedUrl("FingerEnrollmentSkipPage.qml"))
                }
            }
        }
    }

    Image {
        source: "image://theme/graphic-fingersensor"

        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: parent.bottom
        }
    }
}
