import QtQuick 2.0


Item {
    property int timerInterval: 10000
    property bool timerEnabled: false
    property var model

    signal timerTriggered

    Timer {
        interval: parent.timerInterval
        repeat: true
        running: window.applicationActive && timerEnabled && pageStack.currentPage === startPage
        onTriggered: timerTriggered()
    }

}
