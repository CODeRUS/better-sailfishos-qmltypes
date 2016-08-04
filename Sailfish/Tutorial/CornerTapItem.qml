import QtQuick 2.0
import Sailfish.Silica 1.0

MouseArea {
    property int _step

    signal triggered

    function reset() {
        _step = 0
    }

    function _handleClick(number, mouse) {
        mouse.accepted = false
        if (number === 0) {
            _step = 1
        } else if (number === _step) {
            if (number === 3) {
                triggered()
                _step = 0
            } else {
                _step++
            }
        } else {
            _step = 0
        }
    }

    // When corner tap item is hidden, reset.
    onVisibleChanged: if (!visible) _step = 0

    onPressed: {
        // The bottom-left corner accepts mouse when it is clicked as fourth item.
        // Corner clicking order is clock wise from top-left to bottom-left.
        var child = childAt(mouse.x, mouse.y)
        var clickingCornerItem = (child === topLeft ||
                                  child === topRight ||
                                  child === bottomLeft ||
                                  child === bottomRight)
        if (!clickingCornerItem) {
            _step = 0
        }

        mouse.accepted = false
    }

    MouseArea {
        id: topLeft
        objectName: "topLeft"
        anchors { left: parent.left; top: parent.top }
        width: Theme.itemSizeLarge; height: Theme.itemSizeLarge
        enabled: _step == 0
        onClicked: parent._handleClick(0, mouse)
    }

    MouseArea {
        id: topRight
        objectName: "topRight"
        anchors { right: parent.right; top: parent.top }
        width: Theme.itemSizeLarge; height: Theme.itemSizeLarge
        enabled: _step == 1
        onClicked: parent._handleClick(1, mouse)
    }

    MouseArea {
        id: bottomRight
        objectName: "bottomRight"
        anchors { right: parent.right; bottom: parent.bottom }
        width: Theme.itemSizeLarge; height: Theme.itemSizeLarge
        enabled: _step == 2
        onClicked: parent._handleClick(2, mouse)
    }

    MouseArea {
        id: bottomLeft
        objectName: "bottomLeft"
        anchors { left: parent.left; bottom: parent.bottom }
        width: Theme.itemSizeLarge; height: Theme.itemSizeLarge
        enabled: _step == 3
        onClicked: parent._handleClick(3, mouse)
    }
}
