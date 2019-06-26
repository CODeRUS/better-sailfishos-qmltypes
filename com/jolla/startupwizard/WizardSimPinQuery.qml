import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Telephony 1.0
import com.jolla.settings.system 1.0

Page {
    id: root

    property string modemPath

    signal queryDone()

    SimManager {
        id: simManager
    }

    SimPinQuery {
        modemPath: root.modemPath
        showCancelButton: true
        multiSimManager: simManager

        onDone: {
            clear()
            root.queryDone()
        }
        onPinEntryCanceled: {
            clear()
            pageStack.animatorPush(pinQuerySkippedComponent)
        }
        onSimPermanentlyLocked: {
            clear()
            pageStack.animatorReplace(pinLockedNoticeComponent)
        }
    }

    Component {
        id: pinQuerySkippedComponent
        SimPinQuerySkippedNotice {
            onContinueClicked: {
                root.queryDone()
            }
        }
    }

    Component {
        id: pinLockedNoticeComponent
        SimLockedNotice {
            onContinueClicked: {
                root.queryDone()
            }
        }
    }
}
