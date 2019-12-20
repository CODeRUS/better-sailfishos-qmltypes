/*
 * Copyright (c) 2013 - 2019 Jolla Ltd.
 * Copyright (c) 2019 Open Mobile Platform LLC.
 *
 * License: Proprietary
 */

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
            pageStack.animatorPush(pinLockedNoticeComponent)
        }
    }

    Component {
        id: pinQuerySkippedComponent
        Page {
            SimPinQuerySkippedNotice {
                onContinueClicked: {
                    root.queryDone()
                }
            }
        }
    }

    Component {
        id: pinLockedNoticeComponent
        Page {
            SimLockedNotice {
                onContinueClicked: {
                    root.queryDone()
                }
            }
        }
    }
}
