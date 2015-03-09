import QtQuick 2.0
import Sailfish.Silica 1.0
import com.jolla.startupwizard 1.0

Column {
    id: root

    signal acceptClicked()
    signal rejectClicked()

    spacing: Theme.paddingLarge * 2

    WizardClickableLabel {
        width: parent.width
        //% "<u>Accept Sailfish OS Terms of Use</u>"
        text: qsTrId("startupwizard-la-sailfish_terms_accept")

        onClicked: root.acceptClicked()
    }

    WizardClickableLabel {
        width: parent.width
        //% "<u>Reject and turn the phone off</u>"
        text: qsTrId("startupwizard-la-sailfish_terms_reject")

        onClicked: root.rejectClicked()
    }
}
