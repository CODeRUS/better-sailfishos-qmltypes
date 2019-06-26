/****************************************************************************
**
** Copyright (C) 2016 Jolla Ltd.
** Contact: Matt Vogt <matthew.vogt@jollamobile.com>
**
****************************************************************************/

import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Silica.private 1.0 as Private
import Sailfish.Pickers 1.0
import "private"

PickerPage {
    id: filePicker

    property var nameFilters
    // Qt::CaseSensitivity
    property int caseSensitivity: Qt.CaseInsensitive

    property alias showSystemFiles: partitionList.showSystemFiles

    function _filePicked(props) {
        if (!_lastAppPage) {
            _lastAppPage = pageStack.previousPage(filePicker)
        }
        _handleSelectionProperties(props)

    }

    //% "Select location"
    title: qsTrId("components_pickers-he-select_location")

    orientationTransitions: Private.PageOrientationTransition {
        fadeTarget: _background ? listView : __silica_applicationwindow_instance.contentItem
        targetPage: filePicker
    }

    PartitionListView {
        id: partitionList

        header: PageHeader {
            title: filePicker.title
        }

        onSelected: {
            var obj = pageStack.animatorPush('private/DirectoryPage.qml', {
                title: info.name,
                path: info.path,
                nameFilters: filePicker.nameFilters,
                caseSensitivity: filePicker.caseSensitivity,
                _animationDuration: filePicker._animationDuration,
                _background: filePicker._background
            })
            obj.pageCompleted.connect(function(page) {
                page.filePicked.connect(filePicker._filePicked)
            })
        }
    }
}
