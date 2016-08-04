import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Vault 1.0

FullScreenInfoPage {
    id: root

    property bool canCancel

    property string busyHeadingText
    property string busyBodyText

    property string successHeadingText
    property string errorHeadingText
    property string errorDetailText
    property string statusText

    signal done()
    signal cancelRequested()

    topText: busyHeadingText
    bottomLargeText: busyBodyText
    button1Text: root.canCancel
                   //: Cancel the current operation
                   //% "Cancel"
                 ? qsTrId("vault-bt-cancel")
                 : ""

    showProgress: true
    animateLabelOpacity: true
    bottomSmallText: root.statusText

    states: [
        State {
            name: "running"
            PropertyChanges {
                target: root
            }
        },
        State {
            name: "done"
            PropertyChanges {
                target: root
                showProgress: false
                progressImageSource: ""
                progressCaption: ""
                animateLabelOpacity: false
                bottomLargeText: ""
                //% "OK"
                button1Text: qsTrId("vault-bt-ok")
            }
        },
        State {
            name: "success"
            extend: "done"
            PropertyChanges {
                target: root
                topText: root.successHeadingText
            }
            PropertyChanges {
                target: yourFace
                source: "image://theme/graphic-waiting-page-happy"
            }
        },
        State {
            name: "error"
            extend: "done"
            PropertyChanges {
                target: root
                topText: root.errorHeadingText
                bottomSmallText: root.errorDetailText
            }
            PropertyChanges {
                target: yourFace
                source: "image://theme/graphic-waiting-page-sad"
            }
        }
    ]

    onStatusChanged: {
        backupUtils.setSystemGesturesEnabled(root, status != PageStatus.Activating && status != PageStatus.Active)
    }

    onButton1Clicked: {
        if (canCancel) {
            cancelRequested()
        } else {
            done()
        }
    }

    BackupUtils {
        id: backupUtils
    }

    Image {
        id: yourFace
        parent: root.centerSection
        anchors.centerIn: parent
    }
}
