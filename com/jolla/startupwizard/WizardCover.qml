import QtQuick 2.0
import Sailfish.Silica 1.0

CoverBackground {
    id: root

    onStatusChanged: {
        if (status == Cover.Active) {
            coverTextAnim.start()
        } else {
            coverTextAnim.stop()
        }
    }

    Image {
        source: "image://theme/graphic-cover-tutorial"
        anchors.horizontalCenter: parent.horizontalCenter
    }

    Label {
        id: coverTextLabel
        anchors {
            bottom: parent.bottom
            bottomMargin: Theme.paddingLarge
            top: parent.verticalCenter
            horizontalCenter: parent.horizontalCenter
        }
        width: parent.width - 2*Theme.paddingLarge
        color: Theme.secondaryColor
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignBottom
        wrapMode: Text.WordWrap
        fontSizeMode: Text.Fit

        //: Instructs the user to tap this app cover in order to re-open the Jolla tutorial app and continue the tutorial.
        //% "Tap to continue"
        text: qsTrId("startupwizard-la-tutorial_cover_description")
    }

    SequentialAnimation {
        id: coverTextAnim
        loops: Animation.Infinite
        alwaysRunToEnd: true

        FadeAnimation { target: coverTextLabel; from: 0; to: 1; duration: 750 }
        PauseAnimation { duration: 750 }
        FadeAnimation { target: coverTextLabel; from: 1; to: 0; duration: 750 }
    }
}
