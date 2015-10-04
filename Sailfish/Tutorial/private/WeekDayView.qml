import QtQuick 2.0
import Sailfish.Silica 1.0

Row {
    id: weekDayView

    property real itemWidth: Theme.paddingSmall
    spacing: (width - itemWidth*8) / 7

    property string days: ""
    property color color
    Repeater {
        model: 8

        Rectangle {
            property bool active: weekDayView.days.indexOf("mtwTf-sS"[index]) >= 0

            radius: Math.round(Theme.paddingSmall/2)
            width: weekDayView.itemWidth
            // Gap between weekdays and weekend
            color: index == 5 ? "transparent" : weekDayView.color
            opacity: index > 5 ? 0.4 : (active ? 1.0 : 0.6)
            height: active ? weekDayView.height : width
        }
    }
}

