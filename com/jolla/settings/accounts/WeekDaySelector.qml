import QtQuick 2.0
import Sailfish.Silica 1.0

// Comes from com.jolla.activesync 1.0. It uses exactly the same bit field
// mapping for days.

Row {
    id: buttonRow

    property int weekDaysField: 0

    Repeater {
        // This should be replaced by a proper list from mlocale or qlocale,
        // once we have a wrapper for those.
        Component.onCompleted: {
            var result = [ ]
            var dt = new Date(2012, 0, 2)   // Jan 2, 2012 is a Monday

            for (var i=0; i<7; i++) {
                result.push({ text: Qt.formatDateTime(dt, "ddd"), bit: 1 << i })
                dt.setDate(dt.getDate() + 1)
            }
            model = result
        }

        MouseArea {
            height: childrenRect.height
            width: buttonRow.width / 7

            onClicked: button.checked = !button.checked

            Switch {
                id: button
                width: parent.width
                checked: weekDaysField & modelData.bit

                onCheckedChanged: {
                    if (checked) {
                        weekDaysField = weekDaysField | modelData.bit
                    } else {
                        weekDaysField = weekDaysField & ~(modelData.bit)
                    }
                }
            }

            Label {
                id: buttonText
                anchors {
                    horizontalCenter: button.horizontalCenter
                    top: button.bottom
                    topMargin: -Theme.paddingLarge
                }
                text: modelData.text
                font.pixelSize: Theme.fontSizeExtraSmall
            }
        }
    }
}
