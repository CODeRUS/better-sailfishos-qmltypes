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

DocumentPage {
    id: base;

    attachedPage: Component {
        PDFDocumentToCPage {
            tocModel: pdfDocument.tocModel
            onPageSelected: view.goToPage( pageNumber );
        }
    }

    PDFView {
        id: view;

        width: base.width;
        height: base.height;

        document: pdfDocument;

        onClicked: base.open = !base.open;

        ViewPlaceholder {
            enabled: pdfDocument.failure || pdfDocument.locked
            y: (flickable ? flickable.originY : 0) + (base.height - height - (passwd.visible ? passwd.height : 0)) / 2
            //% "Broken file"
            text: pdfDocument.failure ? qsTrId("sailfish-office-me-broken-pdf") :
            //%  "Locked file"
            qsTrId("sailfish-office-me-locked-pdf")
            //% "Cannot read the PDF document"
            hintText: pdfDocument.failure ? qsTrId("sailfish-office-me-broken-pdf-hint") :
            //% "Enter password to unlock"
            qsTrId("sailfish-office-me-locked-pdf-hint")
            MouseArea {
                anchors.fill: parent
                onClicked: base.open = !base.open
            }
            TextField {
                id: passwd
                visible: pdfDocument.locked
                width: parent.width - Theme.paddingLarge
                anchors.top: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter

                //% "password"
                label: qsTrId("sailfish-office-la-password")
                placeholderText: label

                inputMethodHints: Qt.ImhNoPredictiveText | Qt.ImhNoAutoUppercase
                echoMode: TextInput.Password
                EnterKey.enabled: text
                EnterKey.onClicked: {
                    focus = false
                    pdfDocument.requestUnLock(text)
                    text = ""
                }

                onFocusChanged: if (focus) base.open = false
            }
        }

    }

    PDF.Document {
        id: pdfDocument;
        source: base.path;
    }

    busy: !pdfDocument.loaded && !pdfDocument.failure;
    source: pdfDocument.source;
    indexCount: pdfDocument.pageCount;

    Timer {
        id: updateSourceSizeTimer;
        interval: 5000;
        onTriggered: linkArea.sourceSize = Qt.size( base.width, pdfCanvas.height );
    }
}
