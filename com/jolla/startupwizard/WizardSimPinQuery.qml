import QtQuick 2.0
import Sailfish.Silica 1.0
import com.jolla.settings.system 1.0

Page {
    id: root

    property string modemPath

    signal queryDone()

    SimPinQuery {
        modemPath: root.modemPath
        showCancelButton: true

        onDone: {
            clear()
            root.queryDone()
        }
        onPinEntryCanceled: {
            clear()
            pageStack.push(pinQuerySkippedComponent)
        }
        onSimPermanentlyLocked: {
            clear()
            pageStack.replace(pinLockedNoticeComponent)
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
