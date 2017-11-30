/****************************************************************************
**
** Copyright (C) 2016 Jolla Ltd.
** Contact: Matt Vogt <matthew.vogt@jollamobile.com>
**
****************************************************************************/

import QtQml 2.2
import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Silica.private 1.0 as Private
import Sailfish.Gallery 1.0
import Sailfish.Pickers 1.0
import org.nemomobile.systemsettings 1.0
import "private"

PickerPage {
    id: filePicker

    property var nameFilters
    // Qt::CaseSensitivity
    property int caseSensitivity: Qt.CaseInsensitive

    function _filePicked(props) {
        _lastAppPage = pageStack.previousPage(filePicker)
        _handleSelectionProperties(props)

    }

    //% "Select location"
    title: qsTrId("components_pickers-he-select_location")

    ListModel {
        id: sourceModel

        Component.onCompleted: {
            append({
                       //% "Home folder"
                       name: qsTrId("components_pickers-la-home_folder"),
                       iconSource: 'image://theme/icon-m-file-folder',
                       path: StandardPaths.home
                   })
            append({
                       //% "System files"
                       name: qsTrId("components_pickers-la-system_files"),
                       iconSource: 'image://theme/icon-m-file-folder',
                       path: '/'
                   })
        }
    }

    Instantiator {
        model: PartitionModel {
            storageTypes: PartitionModel.External | PartitionModel.ExcludeParents
        }

        delegate: QtObject {
            Component.onCompleted: {
                if (model.status == PartitionModel.Mounted) {
                    sourceModel.append({
                        //% "Memory card"
                        name: qsTrId("components_pickers-la-memory_card"),
                        iconSource: 'image://theme/icon-m-file-folder',
                        path: model.mountPath
                    })
                }
            }
        }
    }

    orientationTransitions: Private.PageOrientationTransition {
        fadeTarget: _background ? listView : __silica_applicationwindow_instance.contentItem
        targetPage: filePicker
    }

    SilicaListView {
        id: listView

        currentIndex: -1
        anchors.fill: parent

        header: PageHeader {
            title: filePicker.title
        }

        model: sourceModel

        delegate: BackgroundItem {
            id: listItem

            width: ListView.view.width
            height: Theme.itemSizeMedium

            Row {
                anchors.fill: parent
                spacing: Theme.paddingLarge
                Rectangle {
                    width: height
                    height: parent.height
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: Theme.rgba(Theme.primaryColor, 0.1) }
                        GradientStop { position: 1.0; color: "transparent" }
                    }

                    Image {
                        anchors.centerIn: parent
                        source: model.iconSource + (highlighted ? "?" + Theme.highlightColor : "")
                    }
                }
                Label {
                    text: model.name
                    width: parent.width - parent.height - parent.spacing - Theme.horizontalPageMargin
                    anchors.verticalCenter: parent.verticalCenter
                    truncationMode: TruncationMode.Fade
                    color: highlighted ? Theme.highlightColor : Theme.primaryColor
                }
            }

            onClicked: {
                var page = pageStack.push('private/DirectoryPage.qml', {
                    title: model.name,
                    path: model.path,
                    nameFilters: filePicker.nameFilters,
                    caseSensitivity: filePicker.caseSensitivity
                })
                page.filePicked.connect(filePicker._filePicked)
            }
        }

        VerticalScrollDecorator {}
    }
}
