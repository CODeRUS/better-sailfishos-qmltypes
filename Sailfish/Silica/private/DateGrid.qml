/****************************************************************************************
**
** Copyright (C) 2013 Jolla Ltd.
** Contact: Bea Lam <bea.lam@jollamobile.com>
** All rights reserved.
** 
** This file is part of Sailfish Silica UI component package.
**
** You may use this file under the terms of BSD license as follows:
**
** Redistribution and use in source and binary forms, with or without
** modification, are permitted provided that the following conditions are met:
**     * Redistributions of source code must retain the above copyright
**       notice, this list of conditions and the following disclaimer.
**     * Redistributions in binary form must reproduce the above copyright
**       notice, this list of conditions and the following disclaimer in the
**       documentation and/or other materials provided with the distribution.
**     * Neither the name of the Jolla Ltd nor the
**       names of its contributors may be used to endorse or promote products
**       derived from this software without specific prior written permission.
** 
** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
** ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
** WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
** DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
** ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
** (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
** LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
** ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
** (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
** SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
**
****************************************************************************************/

import QtQuick 2.0
import Sailfish.Silica 1.0
import "DatePicker.js" as DatePickerScript

Item {
    id: root

    property int displayedYear
    property int displayedMonth
    property date selectedDate
    property var highlightedDate

    property real gridWidth
    property real weekColumnWidth
    property bool needsUpdate

    property Component modelComponent
    property QtObject customModel
    property alias delegate: dateController.delegate

    property int _dateBoxSize: gridWidth / 7
    property int _displayedMonthStartIndex: -1

    signal updateModel(variant modelObject, variant fromDate, variant toDate, int primaryMonth)

    onNeedsUpdateChanged: {
        if (needsUpdate)
            loadMonth(displayedMonth, displayedYear)
    }

    onSelectedDateChanged: _resetSelectedDateBox(selectedDate, selectedDateBox)
    onHighlightedDateChanged: _resetSelectedDateBox(highlightedDate, highlightedDateBox)

    function _resetSelectedDateBox(highlightDate, highlightItem) {
        if (highlightDate !== undefined && highlightDate.getFullYear() == displayedYear && highlightDate.getMonth()+1 == displayedMonth) {
            var index = _displayedMonthStartIndex + (highlightDate.getDate() - 1)
            var itemToHighlight = dateController.itemAt(index)
            if (itemToHighlight != null) {
                _highlightDayItem(itemToHighlight, highlightItem)
            } else {
                // grid has not yet loaded
                highlightWait.start()
            }
        } else {
            highlightItem.visible = false
        }
    }

    Timer {
        id: highlightWait
        interval: 100
        onTriggered: {
            _resetSelectedDateBox(selectedDate, selectedDateBox)
            _resetSelectedDateBox(highlightedDate, highlightedDateBox)
        }
    }

    function loadMonth(month, year) {
        // set the dates in the calendar grid; display 6 weeks
        var fromDate = DatePickerScript._getStartDateForMonthView(year, month)
        _loadDateGrid(fromDate, 7 * 6)       // we display 6 weeks

        _displayedMonthStartIndex = 0
        while (fromDate.getMonth() + 1 !== month) {
            fromDate.setDate(fromDate.getDate() + 1)
            _displayedMonthStartIndex++
        }

        // set the week numbers
        var theMonth = new Date(Date.UTC(year, month-1, 1))
        DatePickerScript._loadWeekNumbers(weekNumberModel, year, month, 6)
        monthName.text = Format.formatDate(theMonth, Format.MonthNameStandaloneShort)
        monthYear.text = theMonth.getFullYear()
    }

    function _highlightDayItem(item, highlightItem) {
        if (!item) {
            return
        }
        var pos = root.mapFromItem(item, 0, 0)
        highlightItem.x = pos.x + (_dateBoxSize/2 - highlightItem.width/2)
        highlightItem.y = pos.y + (_dateBoxSize/2 - highlightItem.height/2)
        highlightItem.visible = true
    }

    function _loadDateGrid(fromDate, totalDays) {
        if (modelComponent !== null && customModel === null) {
            customModel = modelComponent.createObject(root)
        }
        if (customModel !== null) {
            var toDate = new Date(fromDate)
            toDate.setDate(toDate.getDate() + totalDays)
            root.updateModel(customModel, fromDate, toDate, root.displayedMonth)
        } else {
            var dt = new Date(fromDate)
            if (dateModel.count == 0) {
                for (var i=0; i<totalDays; i++) {
                    dateModel.append({'year': dt.getFullYear(),
                                      'month': dt.getMonth()+1,
                                      'day': dt.getDate(),
                                      'primaryMonth': root.displayedMonth})
                    dt.setDate(dt.getDate() + 1)
                }
            } else {
                for (var i=0; i<totalDays; i++) {
                    dateModel.set(i, {'year': dt.getFullYear(),
                                      'month': dt.getMonth()+1,
                                      'day': dt.getDate(),
                                      'primaryMonth': root.displayedMonth})
                    dt.setDate(dt.getDate() + 1)
                }
            }
        }
        _resetSelectedDateBox(selectedDate, selectedDateBox)
    }

    width: gridWidth + weekColumn.width
    height: height

    Label {
        id: monthName
        anchors {
            right: weekColumn.right
            top: parent.top
            topMargin: root._dateBoxSize - font.pixelSize/2
        }
        color: Theme.secondaryHighlightColor
    }

    Label {
        id: monthYear
        anchors {
            right: weekColumn.right
            top: parent.top
            topMargin: root._dateBoxSize*2 - font.pixelSize/2
        }
        color: Theme.secondaryHighlightColor
    }

    Column {
        id: weekColumn

        width: root.weekColumnWidth

        Repeater {
            model: ListModel {
                id: weekNumberModel
            }

            onCountChanged: _resetSelectedDateBox(selectedDate, selectedDateBox)

            Item {
                width: root.weekColumnWidth
                height: root._dateBoxSize

                Label {
                    id: weekLabel
                    //: Used to show week text and week number: %1 == weeknumber
                    //% "week %1"
                    text: qsTrId("components-la-week_and_weeknumber").arg(model.weekNumber)
                    font.pixelSize: Theme.fontSizeExtraSmall
                    color: Theme.highlightColor
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                }
            }
        }
    }

    ListModel {
        id: dateModel
    }

    Rectangle {
        id: selectedDateBox
        width: _dateBoxSize
        height: width
        color: Theme.rgba(Theme.highlightBackgroundColor, Theme.highlightBackgroundOpacity)
        radius: 4
    }

    Rectangle {
        id: highlightedDateBox
        width: _dateBoxSize
        height: width
        color: Theme.rgba(Theme.highlightBackgroundColor, Theme.highlightBackgroundOpacity)
        radius: 4
    }

    Grid {
        anchors.left: weekColumn.right
        columns: 7

        Repeater {
            id: dateController
            model: root.customModel !== null ? root.customModel : dateModel
        }
    }
}
