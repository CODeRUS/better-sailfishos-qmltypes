import QtQuick 2.0

// animation characteristics copied from Silica ViewPlaceholder.qml
SequentialAnimation {
    id: root

    property Item target

    // jumps to left if true, otherwise jumps to right
    property bool hintAtAccept

    NumberAnimation {
        target: root.target
        property: "contentX"
        to: root.hintAtAccept ? 30 : -30
        duration: 300
        easing.type: Easing.OutCubic
    }
    NumberAnimation {
        target: root.target
        property: "contentX"
        to: 0
        duration: 300
        easing.type: Easing.OutCubic
    }
}
