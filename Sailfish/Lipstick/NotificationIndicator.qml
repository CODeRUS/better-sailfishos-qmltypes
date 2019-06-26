/****************************************************************************
 **
 ** Copyright (C) 2015 Jolla Ltd.
 ** Contact: Matt Vogt <matthew.vogt@jollamobile.com>
 **
 ****************************************************************************/

import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Lipstick 1.0

Item {
    id: root

    property int count
    property string iconSource
    property bool showCount: count > 1
    property color textColor: Theme.primaryColor
    property string iconSuffix
    property bool highlighted
    property bool busy

    property string _source: iconSource || "icon-lock-information"
    property string _suffix: highlighted ? "" : iconSuffix
    property real _iconSize: Theme.iconSizeSmall
    property Item _busyIndicator

    height: icon.height
    width: Math.max(countLabel.width + countLabel.anchors.leftMargin + _iconSize + Theme.paddingSmall,
                    _iconSize + 2*Theme.paddingLarge)

    onBusyChanged: {
        if (!_busyIndicator) {
            _busyIndicator = busyIndicatorComp.createObject(root)
        }
    }

    HighlightImage {
        id: icon

        width: root._iconSize
        height: width
        fillMode: Image.PreserveAspectFit
        smooth: true
        opacity: busy ? 0.5 : 1
        sourceSize.width: width
        source: {
            if (_source.indexOf("http") === 0) {
                return _source
            } else if (_source.indexOf("/") === 0) {
                return "image://nemoThumbnail/" + _source
            } else if (_source.indexOf("image://theme/") === 0) {
                return _source + _suffix
            } else {
                return "image://theme/" + _source + _suffix
            }
        }

        highlighted: root.highlighted

        HighlightImage {
            id: errorImage
            anchors.fill: parent
            fillMode: Image.PreserveAspectFit
            source: icon.status == Image.Error ? "image://theme/icon-lock-information" + _suffix : ""
            highlighted: root.highlighted
            monochromeWeight: colorWeight
            highlightColor: Theme.highlightBackgroundColor
        }
    }

    Label {
        id: countLabel

        anchors {
            left: icon.right
            leftMargin: Theme.paddingSmall
            verticalCenter: icon.verticalCenter
        }
        text: root.count > 99 ? '99+' : root.count
        font.pixelSize: Theme.fontSizeSmall
        color: root.highlighted ? Theme.highlightColor : root.textColor
        visible: opacity > 0
        opacity: root.showCount ? 1 : 0

        Behavior on opacity {
            FadeAnimation {}
        }
    }

    Component {
        id: busyIndicatorComp
        BusyIndicator {
            anchors.centerIn: icon
            size: BusyIndicatorSize.ExtraSmall
            running: root.busy
        }
    }
}
