/*
 * Copyright (c) 2019 Open Mobile Platform LLC.
 *
 * License: Proprietary
 */
pragma Singleton

import QtQuick 2.0
import Nemo.FileManager 1.0

Item {
    property int previousFileEngineMode

    function instance () {} // Create singleton

    Connections {
        target: FileEngine
        onModeChanged: {
            if (FileEngine.mode === FileEngine.IdleMode) {
                if (previousFileEngineMode === FileEngine.CopyMode) {
                    //% "Copied"
                    notification.show(qsTrId("filemanager-la-copied"))
                }
                timer.stop()
            } else {
                previousFileEngineMode = FileEngine.mode
                timer.start()
            }
        }
    }

    Timer {
        id: timer
        interval: 1000
        onTriggered: {
            if (FileEngine.mode === FileEngine.CopyMode) {
                //% "Copying"
                notification.show(qsTrId("filemanager-la-copying"))
            }
        }
    }

    FileManagerNotification {
        id: notification
    }
}
