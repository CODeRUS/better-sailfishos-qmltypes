import QtQuick 2.0

MouseArea {
    property int edge: Qt.BottomEdge

    anchors {
        left: edge !== Qt.RightEdge ? parent.left : undefined
        right: edge !== Qt.LeftEdge ? parent.right : undefined
        top: edge !== Qt.BottomEdge ? parent.top : undefined
        bottom: edge !== Qt.TopEdge ? parent.bottom : undefined
    }
    // anchors will override width or height depending on edge
    width: 24 * xScale
    height: 24 * yScale
    preventStealing: true
}
