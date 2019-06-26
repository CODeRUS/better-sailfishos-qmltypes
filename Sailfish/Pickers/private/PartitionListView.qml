/****************************************************************************
**
** Copyright (C) 2017 Jolla Ltd.
** Contact: Raine Mäkeläinen <raine.makelainen@jollamobile.com>
**
****************************************************************************/

import QtQml 2.2
import QtQuick 2.6
import org.nemomobile.systemsettings 1.0
import Sailfish.Silica 1.0

SilicaListView {
    id: listView

    property bool showSystemFiles: true

    signal selected(var info)

    currentIndex: -1
    anchors.fill: parent

    model: sourceModel

    delegate: CategoryItem {
        text: model.name
        iconSource: model.iconSource

        onClicked: listView.selected(model)
    }


    ListModel {
        id: sourceModel

        Component.onCompleted: {
            // Let the Memory Card be always last one
            if (showSystemFiles) {
                insert(0, {
                           //% "System files"
                           name: qsTrId("components_pickers-la-system_files"),
                           iconSource: 'image://theme/icon-m-file-folder',
                           path: '/'
                       })
            }
            insert(0, {
                       //% "Home folder"
                       name: qsTrId("components_pickers-la-home_folder"),
                       iconSource: 'image://theme/icon-m-file-folder',
                       path: StandardPaths.home
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

    VerticalScrollDecorator {}
}
