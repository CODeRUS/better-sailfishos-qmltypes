import QtQuick 2.0
import Nemo.KeepAlive 1.1

Item {
    id: item
    property bool suspend
    onSuspendChanged: DisplayBlanking.preventBlanking = suspend
}
