import QtQuick 2.0
import Sailfish.Silica 1.0

// Creates an Account*Agent instance and emits finished() when the agent has finished
// (i.e. when its pages have been popped off the stack and its delayDeletion=false).

Item {
    id: root

    property var agentProperties: ({})
    property string agentComponentFileName
    property QtObject agent
    property bool hasFinished
    property bool hasCompletedCreation

    property int _initialPageStackDepth: -1
    property bool _accountSaveRequested

    // Emited when the agent has completed all tasks
    signal finished()
    // Emited when the account creation is finished, the agent might do some extra tasks
    // in the background after that, but all pages are already pop from the stack
    signal completedCreation()

    function _checkFinished() {
        // the _initialPageStackDepth must be checked to avoid deleting the agent
        // when its initialPage has been replaced rather than that the agent has
        // poppped all of its pages
        if (!agent.delayDeletion && !hasFinished && pageStack.depth < _initialPageStackDepth
                && agent.initialPage.pageContainer == null) {

            // complete and emit finished()
            hasFinished = true
            finished()
        }
    }

    function _checkCompletedCreation() {
        if (agent.initialPage.pageContainer == null && !hasCompletedCreation) {
            // Because the agent pages are not necessarily destroyed as soon as finished() is
            // emitted, if they have any textfields with active focus, the vkb may reappear
            // when the agent pages are closed. Reset the focus here to prevent this.
            focus = true

            hasCompletedCreation = true
            completedCreation()
        }
    }

    function _newAgent() {
        var comp = Qt.createComponent(agentComponentFileName)
        if (comp.status !== Component.Ready) {
            throw new Error("Cannot load " + agentComponentFileName + ": " + comp.errorString())
        }
        var obj = comp.createObject(root, agentProperties)
        if (obj === null) {
            throw new Error("Unable to instantiate", agentComponentFileName)
        }
        return obj
    }

    Component.onCompleted: {
        agent = _newAgent()
        agent.delayDeletionChanged.connect(function() {
            _checkFinished()
            _checkCompletedCreation()
        })
    }

    Connections {
        target: agent != null ? agent.initialPage : null
        onPageContainerChanged: {
            if (agent.initialPage.pageContainer == null) {
                _checkFinished()
                _checkCompletedCreation()
            }
        }
        onStatusChanged: {
            if (_initialPageStackDepth < 0 && agent.initialPage.status == PageStatus.Active) {
                _initialPageStackDepth = pageStack.depth
            }
        }
    }
}
