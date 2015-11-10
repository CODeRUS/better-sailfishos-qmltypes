/*
 * Copyright (C) 2013-2014 Jolla Ltd.
 * Contact: Robin Burchell <robin.burchell@jolla.com>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; version 2 only.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Office.PDF 1.0 as PDF

SilicaFlickable {
    id: base;

    contentWidth: pdfCanvas.width;
    contentHeight: pdfCanvas.height;

    property alias itemWidth: pdfCanvas.width;
    property alias itemHeight: pdfCanvas.height;
    property alias document: pdfCanvas.document;
    property alias currentPage: pdfCanvas.currentPage

    property bool scaled: pdfCanvas.width != width;

    signal clicked();
    signal updateSize(real newWidth, real newHeight);

    function clamp(value) {
        if (value < width) {
            return width;
        }

        if (value > width * 2.5) {
            return width * 2.5;
        }

        return value;
    }

    function zoom(amount, center) {
        var oldWidth = pdfCanvas.width;
        var oldHeight = pdfCanvas.height
        var oldContentX = contentX
        var oldContentY = contentY

        pdfCanvas.width = clamp(pdfCanvas.width * amount);

        /* One cannot use += here because changing contentX will change contentY
           to adjust to new height, so we use saved values. */
        contentX = oldContentX + (center.x * pdfCanvas.width / oldWidth) - center.x
        contentY = oldContentY + (center.y * pdfCanvas.height / oldHeight) - center.y
    }

    function adjust() {
        var oldWidth = pdfCanvas.width
        var oldHeight = pdfCanvas.height
        var oldContentX = contentX
        var oldContentY = contentY

        pdfCanvas.width = scaled ? clamp(pdfCanvas.width) : width

        contentX = oldContentX * pdfCanvas.width / oldWidth
        contentY = oldContentY * pdfCanvas.height / oldHeight
    }

    function moveToSearchMatch(index) {
        if (index < 0 || index >= searchDisplay.count) return

        searchDisplay.currentIndex = index
        
        var match = searchDisplay.itemAt(index)
        var cX = match.x + match.width / 2. - width / 2.
        transX.to = (cX < 0) ? 0 : (cX > pdfCanvas.width - width) ? pdfCanvas.width - width : cX
        var cY = match.y + match.height / 2. - height / 2.
        transY.to = (cY < 0) ? 0 : (cY > pdfCanvas.height - height) ? pdfCanvas.height - height : cY

        scaleIn.target = match
        scaleOut.target = match

        focusSearchMatch.start()
    }

    function nextSearchMatch() {
        if (searchDisplay.currentIndex + 1 >= searchDisplay.count) {
            moveToSearchMatch(0)
        } else {
            moveToSearchMatch(searchDisplay.currentIndex + 1)
        }
    }

    function prevSearchMatch() {
        if (searchDisplay.currentIndex < 1) {
            moveToSearchMatch(searchDisplay.count - 1)
        } else {
            moveToSearchMatch(searchDisplay.currentIndex - 1)
        }
    }

    SequentialAnimation {
        id: focusSearchMatch
        ParallelAnimation {
            NumberAnimation { id: transX; target: base; property: "contentX"; duration: 400; easing.type: Easing.InOutCubic }
            NumberAnimation { id: transY; target: base; property: "contentY"; duration: 400; easing.type: Easing.InOutCubic }
        }
        SequentialAnimation {
            NumberAnimation { id: scaleIn; property: "scale"; duration: 200; to: 3.; easing.type: Easing.InOutCubic }
            NumberAnimation { id: scaleOut; property: "scale"; duration: 200; to: 1.; easing.type: Easing.InOutCubic }
        }
    }

    // Ensure proper zooming level when device is rotated.
    onWidthChanged: adjust()

    PDF.Canvas {
        id: pdfCanvas;

        width: base.width;

        spacing: Theme.paddingLarge;
        flickable: base;
        linkColor: Theme.highlightColor;

        PinchArea {
            anchors.fill: parent;
            onPinchUpdated: {
                var newCenter = mapToItem(pdfCanvas, pinch.center.x, pinch.center.y)
                base.zoom(1.0 + (pinch.scale - pinch.previousScale), newCenter);
            }
            onPinchFinished: base.returnToBounds();

            PDF.LinkArea {
                anchors.fill: parent;

                canvas: pdfCanvas;
                onLinkClicked: Qt.openUrlExternally(linkTarget);
                onClicked: base.clicked();
            }
        }

        Repeater {
            id: searchDisplay
            property int currentIndex
            model: pdfCanvas.document.searchModel
            onModelChanged: moveToSearchMatch(0)

            delegate: Rectangle {
                property int page: model.page
                property rect pageRect: model.rect
                property rect match: pdfCanvas.fromPageToItem(page, pageRect)
                Connections {
                    target: pdfCanvas
                    onPageLayoutChanged: match = pdfCanvas.fromPageToItem(page, pageRect)
                }

                opacity: 0.5;
                color: Theme.highlightColor;
                x: match.x - Theme.paddingSmall / 2;
                y: match.y - Theme.paddingSmall / 4;
                width: match.width + Theme.paddingSmall;
                height: match.height + Theme.paddingSmall / 2;
            }
        }
    }

    children: [
        HorizontalScrollDecorator { color: Theme.highlightDimmerColor; },
        VerticalScrollDecorator { color: Theme.highlightDimmerColor; }
    ]

    function goToPage(pageNumber) {
        base.contentY = pdfCanvas.pagePosition( pageNumber );
    }
}
