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

.pragma library

// if this can change dynamically, needs to be a QML property instead
// and also should refer to some settings instead (theme?)
var _weekStartsOnMonday = true

function _isLeapYear(year) {
    return ((year % 4 == 0) && (year % 100 != 0))
            || (year % 400 == 0)
}

function _maxDaysForMonth(month, year) {
    switch (month) {
    case 2:
        return _isLeapYear(year) ? 29 : 28;
    case 4:
    case 6:
    case 9:
    case 11:
        return 30;
    default:
        return 31;
    }
}

// Returns the day (1-31) that is the first day of the week when displaying
// the given month. Given month should be 1-12.
// i.e. the returned date is in either this month or the last week of the
// previous month
function _getStartDateForMonthView(year, month) {
    var start = new Date(Date.UTC(year, month-1, 1))
    if (start.getDay() > 0) {
        start.setDate(start.getDate() - start.getDay())
    }
    if (_weekStartsOnMonday) {
        start.setDate(start.getDate() + 1)
        if (start.getDate() > 1 && start.getMonth()+1 === month) {
            // shifting forward to Monday skipped over the 1st of this month, go back a week
            // to the last Monday of last month
            start.setDate(start.getDate() - 7)
        }
    }
    return start
}

// Returns an array of week numbers for the given month. The weekCount is the
// number of weeks to put in the returned array; e.g. if month=1 and
// weekCount=6 this returns [1,2,3,4,5,6] or possibly [52,1,2,3,4,5] if Jan 1st
// falls after Thursday for this year.
// Given month should be 1-12.
function _loadWeekNumbers(model, year, month, weekCount) {
    var dt = new Date(Date.UTC(year, month-1, 1))
    var num = _weekNumberForDate(dt)
    for (var i=0; i<weekCount; i++) {
        if (model.count <= i) {
            model.append({'weekNumber': num})
        } else {
            model.setProperty(i, 'weekNumber', num)
        }

        // get next week number
        dt.setDate(dt.getDate() + 7)
        if ((month === 1 && num !== 1) || month === 12) {
            // may display week 52 in Jan calendar or week 1 in Dec
            num = _weekNumberForDate(dt)
        } else {
            num++
        }
    }
}

// Qt.weekNumber() is not available in Qt5 - using:
// http://stackoverflow.com/questions/6117814/get-week-of-year-in-javascript-like-in-php
function _weekNumberForDate(dt) {
    //return Qt.weekNumber(dt)

    // Set to nearest Thursday: current date + 4 - current day number
    // Make Sunday's day number 7
    dt.setDate(dt.getDate() + 4 - (dt.getDay()||7))
    // Get first day of year
    var yearStart = new Date(dt.getFullYear(),0,1)
    // Calculate full weeks to nearest Thursday
    var weekNo = Math.ceil(( ( (dt - yearStart) / 86400000) + 1)/7)
    return weekNo
}

