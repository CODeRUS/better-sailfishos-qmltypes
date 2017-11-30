import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    id: timerItem

    property QtObject alarm: model

    height: column.height + 2*Theme.paddingMedium

    Column {
        id: column
        y: Theme.paddingMedium
        spacing: Theme.paddingSmall
        Behavior on opacity { FadeAnimation {} }
        anchors {
            horizontalCenter: parent.horizontalCenter
            horizontalCenterOffset: model.index % columnCount === 0 ? Theme.paddingSmall
                                                          :  model.index % columnCount === (columnCount-1) ? -Theme.paddingSmall
                                                                                   : 0
        }
        width: parent.width-Theme.paddingLarge-Theme.paddingSmall
        Rectangle {
            id: circle
            width: parent.width
            height: width
            radius: width/2
            color: "transparent"
            border {
                color: timerItem.highlighted ? tutorialTheme.highlightColor : tutorialTheme.primaryColor
                width: 2
            }
            smooth: true

            // TODO min/sec: opacity 0.6
            Label {
                id: timeText
                anchors.centerIn: circle
                horizontalAlignment: Qt.AlignHCenter
                verticalAlignment: Qt.AlignVCenter
                textFormat: Text.RichText
                font {
                    pixelSize: Theme.fontSizeLarge
                    family: Theme.fontFamilyHeading
                }


                text: timeString(alarm.duration)
                color: timerItem.highlighted ? tutorialTheme.highlightColor : tutorialTheme.primaryColor

                function timeString(duration) {
                    var mins = Math.floor(duration / 60)
                    var secs = duration % 60
                    var text = ""

                    if (mins > 0 && secs > 0) {
                        //: Duration of the timer, displayed in the circle, with minutes and seconds. Should be same as clock-va-timer_duration_min_sec
                        //: %1 is minutes, %2 is seconds, put smaller text between <sm> and </sm>
                        //% "%1<sm>min</sm><br>%2<sm>sec</sm>"
                        text = qsTrId("tutorial-va-timer_duration_min_sec").arg(mins).arg(secs)
                    } else if (mins > 0 && secs == 0) {
                        //: Duration of the timer, displayed in the circle, with only minutes. Should be same as clock-va-timer_duration_min
                        //: %1 is minutes, put smaller text between <sm> and </sm>
                        //% "%1<sm>min</sm>"
                        text = qsTrId("tutorial-va-timer_duration_min").arg(mins)
                    } else {
                        //: Duration of the timer, displayed in the circle, with only seconds. Should be same as clock-va-timer_duration_sec
                        //: %1 is seconds, put smaller text between <sm> and </sm>
                        //% "%1<sm>sec</sm>"
                        text = qsTrId("tutorial-va-timer_duration_sec").arg(secs)
                    }

                    // Replace <sm> and </sm> with span
                    text = text.replace(/<sm>/g, "<span style='font-size:" + (Theme.fontSizeExtraSmall) + "px'>")
                    text = text.replace(/<\/sm>/g, "</span>")
                    return text
                }
            }
        }
        Label {
            id: nameText
            width: parent.width
            color: timerItem.highlighted ? tutorialTheme.secondaryHighlightColor : tutorialTheme.secondaryColor
            horizontalAlignment: implicitWidth > width ? Qt.AlignLeft : Qt.AlignHCenter
            font.pixelSize: Theme.fontSizeSmall // For consistency with AlarmItem
            text: alarm.title
            truncationMode: TruncationMode.Fade
        }
    }
}

