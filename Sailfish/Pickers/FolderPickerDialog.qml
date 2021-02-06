/****************************************************************************
**
** Copyright (c) 2020 Open Mobile Platform LLC.
**
****************************************************************************/

import QtQuick 2.0
import Sailfish.Silica 1.0
import Nemo.FileManager 1.0
import Sailfish.FileManager 1.0
import Sailfish.Silica.private 1.0 as Private
import "private"

Dialog {
    id: page

    property string selectedPath
    property string title
    property var _homePage: page

    property alias sortBy: fileModel.sortBy
    property alias sortOrder: fileModel.sortOrder
    property alias directorySort: fileModel.directorySort
    property alias caseSensitivity: fileModel.caseSensitivity

    property alias path: fileModel.path

    property string _folderText: path.split("/").pop()
    /*
     * When the user selects "back", the path needs to be changed to the previous one.
     * To do this, initialize selectedPath only if accepted.
     * But we also need to know if the path is selected by a long press
    */
    property string _pressAndHoldPath

    orientationTransitions: Private.PageOrientationTransition {
        fadeTarget: __silica_applicationwindow_instance.contentItem
        targetPage: page
    }

    onStatusChanged: {
        if (page.status === PageStatus.Active) {
            if (!acceptDestination && (page === _homePage)) {
                acceptDestination = pageStack.previousPage(page)
            }
        }
    }

    onAccepted: {
        if (_pressAndHoldPath) {
            _homePage.selectedPath = _pressAndHoldPath
        } else if (!_homePage.selectedPath) {
            _homePage.selectedPath = page.path
        }
    }
    acceptDestinationAction: PageStackAction.Pop

    SilicaListView {
        id: listView

        currentIndex: -1
        anchors.fill: parent

        header: DialogHeader {
            id: header

            //% "Back"
            cancelText: qsTrId("components_pickers-he-multiselect_dialog_back")

            width: parent.width
            // The empty string makes the button inactive. However, we need to add custom accept text
            acceptText: " "

            _children: Column {
                anchors.verticalCenter: parent.verticalCenter
                Label {
                    text: page.title
                    color: highlighted
                           ? header.palette.highlightColor
                           : header.palette.primaryColor
                    width: header.width/2 - Theme.paddingLarge - Theme.horizontalPageMargin
                    truncationMode: TruncationMode.Fade
                    font.pixelSize: isPortrait ? Theme.fontSizeLarge : Theme.fontSizeMedium
                    horizontalAlignment: Qt.AlignRight
                }

                Label {
                    text: page._folderText
                    color: Theme.secondaryColor
                    width: header.width/2 - Theme.paddingLarge - Theme.horizontalPageMargin
                    truncationMode: TruncationMode.Fade
                    font.pixelSize: isPortrait ? Theme.fontSizeSmall : Theme.fontSizeExtraSmall
                    horizontalAlignment: Qt.AlignRight
                }
            }
        }

        model: FileModel {
            id: fileModel

            path: StandardPaths.home
            active: page.status === PageStatus.Active
            includeDirectories: true
            includeFiles: false
            sortBy: FileModel.SortByName
            directorySort: FileModel.SortDirectoriesBeforeFiles
        }

        delegate: FileBackgroundItem {
            baseName: model.isDir ? model.fileName : model.baseName
            extension: model.isDir ? "" : (model.extension != "" ? "." + model.extension : "")
            mimeType: model.mimeType
            size: model.size
            isDir: model.isDir
            created: model.created
            modified: model.modified
            selected: listView.currentIndex === model.index

            onClicked: {
                listView.currentIndex = -1

                var obj = pageStack.animatorPush('FolderPickerDialog.qml', {
                                                     path: model.absolutePath,
                                                     sortBy: fileModel.sortBy,
                                                     sortOrder: fileModel.sortOrder,
                                                     directorySort: fileModel.directorySort,
                                                     caseSensitivity: fileModel.caseSensitivity,
                                                     acceptDestination: page.acceptDestination,
                                                     acceptDestinationAction: page.acceptDestinationAction,
                                                     _homePage: _homePage,
                                                     _folderText: model.fileName,
                                                     title: page.title,
                                                     allowedOrientations: page.allowedOrientations
                                                 })
                obj.pageCompleted.connect(function(nextPage) {
                    if (page._pressAndHoldPath !== "") {
                        page._pressAndHoldPath = ""
                        page._folderText = page.path.split("/").pop()
                    }
                    nextPage.accepted.connect(function() {
                        page._dialogDone(DialogResult.Accepted)
                    })
                })
            }
            onPressAndHold: {
                listView.currentIndex = model.index
                page._folderText = model.fileName
                _pressAndHoldPath = model.absolutePath
            }
        }

        ViewPlaceholder {
            //% "Empty folder"
            text: qsTrId("components_pickers-ph-empty_folder")

            enabled: listView.count == 0 && fileModel.populated
        }

        VerticalScrollDecorator {}
    }

}
