import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Silica.private 1.0 as Private

FullScreenInfoPage {
    id: root

    property string busyHeadingText
    property string busyBodyText

    property string successHeadingText
    property string errorHeadingText
    property string errorDetailText
    property string statusText

    //: Cancel the current operation
    //% "Cancel"
    property string defaultCancelText: qsTrId("vault-bt-cancel")

    //% "OK"
    property string defaultOKText: qsTrId("vault-bt-ok")

    topText: busyHeadingText
    bottomLargeText: busyBodyText

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

    Private.WindowGestureOverride {
        active: status == PageStatus.Activating || status == PageStatus.Active
    }

    Image {
        id: yourFace
        parent: root.centerSection
        anchors.centerIn: parent
    }
}
