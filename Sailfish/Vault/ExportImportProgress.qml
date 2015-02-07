import QtQuick 2.0
import Sailfish.Silica 1.0

Column {
    id: progressWidget
    property string stage: ""
    property string info: ""
    property string timeText: ""
    property double progress: 0
    property bool canEstimate: (stage === "Copy")

    function imageForStage() {
        var ids = {
            "Copy": "image://theme/icon-l-storage",
            "Validate": "image://theme/icon-l-storage",
            "Pin": "image://theme/icon-l-backup",
            "Flush": "image://theme/icon-l-backup"
        };
        return ids[stage] || "";
    }

    ProgressCircle {
        id: progressCircle
        width: parent.width
        height: width
        value: progressWidget.progress
        BusyIndicator {
            anchors.centerIn: parent
            running: !canEstimate
            size: BusyIndicatorSize.Large
        }
        // Temporary solution: using image to show during stages with
        // unpredictable duration
        Image {
            opacity: canEstimate ? 0 : 1
            Behavior on opacity { FadeAnimation {} }
            anchors.centerIn: parent
            source: imageForStage()

        }
        Column {
            opacity: canEstimate ? 1 : 0
            Behavior on opacity { FadeAnimation {} }
            width: parent.width
            anchors.centerIn: parent
            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                color: Theme.primaryColor
                //% "%1%"
                text: qsTrId("vault-me-progress-percentage")
                    .arg(Math.round(progress * 100))
            }
            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                text: info
            }
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                Image {
                    anchors.verticalCenter: parent.verticalCenter
                    visible: timeText !== ""
                    source: "image://theme/icon-s-time"
                }
                Label {
                    anchors.verticalCenter: parent.verticalCenter
                    text: timeText
                }
            }
        }
    }
}
