/****************************************************************************
**
** Copyright (C) 2017 Jolla Ltd.
** Contact: Raine Mäkeläinen <raine.makelainen@jolla.com>
**
****************************************************************************/

import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Silica.private 1.0 as Private
import Sailfish.Pickers 1.0
import "private"

PickerDialog {
    id: filePicker

    property var nameFilters
    // Qt::CaseSensitivity
    property int caseSensitivity: Qt.CaseInsensitive

    property alias showSystemFiles: partitionList.showSystemFiles

    //% "Select location"
    property string title: qsTrId("components_pickers-he-select_location")

    property var _maskedAcceptDestination

    forwardNavigation: _selectedCount > 0
    acceptDestination: forwardNavigation ? _maskedAcceptDestination : null

    orientationTransitions: Private.PageOrientationTransition {
        fadeTarget: _background ? listView : __silica_applicationwindow_instance.contentItem
        targetPage: filePicker
    }

    PartitionListView {
        id: partitionList

        header: Loader {
            id: headerLoader
            width: parent.width

            sourceComponent: _selectedCount > 0 ? dialogHeader : pageHeader

            Component {
                id: pageHeader
                PageHeader {
                    title: filePicker.title
                }
            }

            Component {
                id: dialogHeader
                PickerDialogHeader {
                    showBack: !_clearOnBackstep
                    selectedCount: _selectedCount
                    _glassOnly: _background
                }
            }
        }

        onSelected: {
            var obj = pageStack.animatorPush('private/DirectoryDialog.qml', {
                                                 title: info.name,
                                                 path: info.path,
                                                 nameFilters: filePicker.nameFilters,
                                                 caseSensitivity: filePicker.caseSensitivity,
                                                 acceptDestination: filePicker._maskedAcceptDestination,
                                                 acceptDestinationAction: filePicker.acceptDestinationAction,
                                                 _selectedModel: filePicker._selectedModel,
                                                 _animationDuration: filePicker._animationDuration,
                                                 _background: filePicker._background
                                             })

            obj.pageCompleted.connect(function(page) {
                page.accepted.connect(function() {
                    filePicker._dialogDone(DialogResult.Accepted)
                })
            })
        }
    }
}
