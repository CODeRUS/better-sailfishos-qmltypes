/**
 * @file ActionItem.qml
 * @brief Universal action item
 * @copyright (C) 2014 Jolla Ltd.
 * @par License: LGPL 2.1 http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html
 */

import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    id: self
    width: parent.width
    height: dataArea.height

    property string actionName: ""
    property string description: ""
    property string remorseText: ""
    property string url: ""
    property bool requiresReboot: false
    property bool deviceLockRequired: true

    signal done(string name)
    signal error(string name, string error)

    property var remorse: undefined

    Component.onCompleted: {
        self.done.connect(actionList.done);
        self.error.connect(actionList.error);
    }

    function executeAction() {
        var on_reply = function() {
            mainPage.inProgress = false;
            console.log("Done:", actionName);
            self.done(actionName);
            if (requiresReboot)
                reboot();
        };
        var on_error = function(err) {
            mainPage.inProgress = false;
            // TODO show error message
            console.log(actionName, " error:", err);
            self.error(actionName, err);
        };
        console.log("Start", actionName);
        mainPage.inProgress = true;
        action(on_reply, on_error);
    }

    Column {
        id: dataArea
        width: parent.width

        Text {
            anchors {
                left: parent.left
                right: parent.right
                margins: Theme.paddingLarge
            }
            color: Theme.highlightColor
            textFormat: Text.StyledText
            linkColor: Theme.primaryColor
            font.pixelSize: Theme.fontSizeSmall
            wrapMode: Text.Wrap
            text: description
            onLinkActivated: Qt.openUrlExternally(link)
        }
        Item { width: parent.width; height: Theme.paddingMedium }
        Label {
            anchors {
                left: parent.left
                right: parent.right
                margins: Theme.paddingLarge
            }
            wrapMode: Text.Wrap
            visible: requiresReboot
            color: Theme.highlightColor
            font.pixelSize: Theme.fontSizeSmall
            //% "This action requires reboot."
            text: qsTrId("sailfish-tools-me-require-reboot")
        }
        Button {
            id: btn
            Component {
                id: remorseComponent
                RemorseItem { }
            }

            function remorseAction(text, action, timeout) {
                // null parent because a reference is held by RemorseItem until
                // it either triggers or is cancelled.
                if (!self.remorse)
                    remorse = remorseComponent.createObject(self)//null)
                remorse.execute(dataArea, text, action, timeout)
            }

            text: actionName
            height: Theme.itemSizeSmall
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: {
                var executeAfterRemorse = function() {
                    remorseAction(remorseText, executeAction, 5000);
                };
                var fn = remorseText ? executeAfterRemorse : executeAction;
                if (deviceLockRequired) {
                    requestLockCode(fn);
                } else {
                    fn();
                }
            }
        }
    }
}
