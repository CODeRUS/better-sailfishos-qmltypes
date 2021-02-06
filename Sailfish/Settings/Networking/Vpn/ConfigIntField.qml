import QtQuick 2.0
import Sailfish.Silica 1.0

ConfigTextField {
    property int intUpperLimit: 2000000000 // QML int max
    property int intLowerLimit: 1
    readonly property string filteredText: text !== '' && !errorHighlight ? parseInt(text, 10).toString() : ''

    inputMethodHints: Qt.ImhDigitsOnly

    errorHighlight: !acceptableInput
    validator: IntValidator { bottom: intLowerLimit; top: intUpperLimit }
}
