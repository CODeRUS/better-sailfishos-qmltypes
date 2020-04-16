import QtQuick 2.6
import Sailfish.Silica 1.0

Row {
    id: root

    property var simManager
    property string imsi
    property real maximumWidth
    property alias showSimOperator: simLabel.visible

    property color color: palette.secondaryColor
    property color highlightColor: palette.secondaryHighlightColor

    readonly property int _modemIndex: simManager && simManager.simNames.length && imsi.length > 0
                                       ? simManager.indexOfModemFromImsi(imsi)
                                       : -1

    visible: simManager && simManager.enabledModems.length > 1
    padding: Theme.paddingSmall

    HighlightImage {
        id: simIcon

        anchors.verticalCenter: parent.verticalCenter
        color: root.color
        highlightColor: root.highlightColor
        source: {
            switch (root._modemIndex) {
                case 0: return "image://theme/icon-s-sim-1"
                case 1: return "image://theme/icon-s-sim-2"
                default: return ""
            }
        }
    }

    Label {
        id: simLabel

        anchors.verticalCenter: parent.verticalCenter
        width: root.maximumWidth > 0
               ? Math.min(implicitWidth, root.maximumWidth - simIcon.width)
               : implicitWidth

        text: root._modemIndex >= 0
              ? root.simManager.modemSimModel.get(root._modemIndex).operatorDescription
              : ""
        truncationMode: TruncationMode.Fade
        font.pixelSize: Theme.fontSizeSmall
        color: highlighted ? root.highlightColor : root.color
    }
}
