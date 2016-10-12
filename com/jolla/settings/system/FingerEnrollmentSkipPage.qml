import QtQuick 2.2
import Sailfish.Silica 1.0
import com.jolla.settings.system 1.0
import org.nemomobile.devicelock 1.0

FingerEnrollmentPage {
    id: page

    acceptDestination: destination
    acceptDestinationAction: PageStackAction.Replace

    header {
        //: Answer 'Yes' to the question "Are you sure want to skip?"
        //% "Yes"
        acceptText: qsTrId("settings_devicelock-la-skip_yes")

        //: Answer 'No' to the question "Are you sure want to skip?"
        //% "No"
        cancelText: qsTrId("settings_devicelock-la-skip_no")
    }

    //% "Skip setting up the fingerprint sensor"
    instruction: qsTrId("settings_devicelock-la-skip_fingerprint")

    //% "You are able to set up the fingerprint sensor in Settings | Device lock."
    explanation: qsTrId("settings_devicelock-la-skip_fingerprint_explanation")
}
