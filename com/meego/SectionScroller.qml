/****************************************************************************
**
** Copyright (C) 2012 Robin Burchell <robin+mer@viroteck.net>
** Copyright (C) 2011 Nokia Corporation and/or its subsidiary(-ies).
**
** This file is part of the Qt Components project.
**
** $QT_BEGIN_LICENSE:BSD$
** You may use this file under the terms of the BSD license as follows:
**
** "Redistribution and use in source and binary forms, with or without
** modification, are permitted provided that the following conditions are
** met:
**   * Redistributions of source code must retain the above copyright
**     notice, this list of conditions and the following disclaimer.
**   * Redistributions in binary form must reproduce the above copyright
**     notice, this list of conditions and the following disclaimer in
**     the documentation and/or other materials provided with the
**     distribution.
**   * Neither the name of Nokia Corporation and its Subsidiary(-ies) nor
**     the names of its contributors may be used to endorse or promote
**     products derived from this software without specific prior written
**     permission.
**
** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
** "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
** LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
** A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
** OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
** SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
** LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
** DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
** THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
** (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
** OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE."
** $QT_END_LICENSE$
**
****************************************************************************/

import QtQuick 2.0
import "." 2.0
import "SectionScroller.js" as Sections

Item {
    id: root

    property ListView listView

    onListViewChanged: {
        if (listView && listView.model) {
            internal.initDirtyObserver();
        } else if (listView) {
            listView.modelChanged.connect(function() {
                if (listView.model) {
                    internal.initDirtyObserver();
                }
            });
        }
    }

    property Style platformStyle: SectionScrollerStyle {}

    //Deprecated, TODO Remove this on w13
    property alias style: root.platformStyle

    MouseArea {
        id: container
        width: 80
        height: listView.height
        x: listView.x + listView.width - width
        property bool dragging: false
        // we manage the drag in positionAtY ourselves, because we 
        // have some extra requirements about positioning
        drag.minimumY: 0
        drag.maximumY: listView.height - tooltip.height
        preventStealing: true

        Rectangle {
            id: sidebar
            anchors.fill: parent
            color: Qt.rgba(1, 1, 1, 0.5)
            opacity: 0

            states: [
                State {
                    name: "dragging"; when: container.dragging
                    PropertyChanges { target: sidebar; opacity: 1.0 }
                }
            ]

            Behavior on opacity {
                NumberAnimation { duration: 100 }
            }
        }

        onPressed: {
            mouseDownTimer.start()
        }

        onReleased: {
            container.dragging = false;
            mouseDownTimer.stop()
        }

        onPositionChanged: {
            internal.adjustContentPosition(container.mouseY);
            tooltip.positionAtY(container.mouseY);
        }

        Timer {
            id: mouseDownTimer
            interval: 150

            onTriggered: {
                container.dragging = true;
                internal.adjustContentPosition(container.mouseY);
                tooltip.positionAtY(container.mouseY);
            }
        }
        Item {
            id: tooltip
            objectName: "popup"
            opacity: container.dragging ? 1 : 0
            anchors.right: parent.right
            width: listView.width
            height: childrenRect.height

            function positionAtY(yCoord) {
                tooltip.y = Math.max(container.drag.minimumY, Math.min(yCoord - tooltip.height/2, container.drag.maximumY));
            }

            Rectangle {
                id: background
                width: parent.width
                height: childrenRect.height// + 20
                anchors.left: parent.left
                color: Qt.rgba(0, 0, 0, 0.5)

                    SectionScrollerLabel {
                        id: currentSectionLabel
                        objectName: "currentSectionLabel"
                        text: internal.currentSection
                        highlighted: true
                        up: !internal.down
                    }
                }

            states: [
                State {
                    name: "visible"
                    when: container.dragging
                },

                State {
                    extend: "visible"
                    name: "atTop"
                    when: internal.curPos === "first"
                    PropertyChanges {
                        target: currentSectionLabel
                        text: internal.nextSection
                    }
                },

                State {
                    extend: "visible"
                    name: "atBottom"
                    when: internal.curPos === "last"
                    PropertyChanges {
                        target: currentSectionLabel
                        text: internal.prevSection
                    }
                }
            ]

            Behavior on opacity {
                NumberAnimation { duration: 100 }
            }
        }
    }

    Timer {
        id: dirtyTimer
        interval: 100
        running: false
        onTriggered: {
            Sections.initSectionData(listView);
            internal.modelDirty = false;
        }
    }

    Connections {
        target: root.listView
        onCurrentSectionChanged: internal.curSect = container.dragging ? internal.curSect : ""
    }

    QtObject {
        id: internal

        property string prevSection: ""
        property string currentSection: listView.currentSection
        property string nextSection: ""
        property string curSect: ""
        property string curPos: "first"
        property int oldY: 0
        property bool modelDirty: false
        property bool down: true

        function initDirtyObserver() {
            Sections.initialize(listView);
            function dirtyObserver() {
                if (!internal.modelDirty) {
                    internal.modelDirty = true;
                    dirtyTimer.running = true;
                }
            }

            // TODO: on model changing, these should also be disconnected.
            if (listView.model.itemsChanged)
                listView.model.itemsChanged.connect(dirtyObserver);

            if (listView.model.itemsMoved)
                listView.model.itemsMoved.connect(dirtyObserver);

            listView.countChanged.connect(dirtyObserver)
        }

        function adjustContentPosition(y) {
            if (y < 0 || y > container.height) return;

            internal.down = (y > internal.oldY);
            var sect = Sections.getClosestSection((y / container.height), internal.down);
            internal.oldY = y;
            if (internal.curSect != sect) {
                internal.curSect = sect;
                internal.curPos = Sections.getSectionPositionString(internal.curSect);
                var sec = Sections.getRelativeSections(internal.curSect);
                internal.prevSection = sec[0];
                internal.currentSection = sec[1];
                internal.nextSection = sec[2];
                var idx = Sections.getIndexFor(sect);
                listView.positionViewAtIndex(idx, ListView.Beginning);
            }
        }

    }
}
