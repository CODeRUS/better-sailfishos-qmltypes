import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Vault 1.0
import NemoMobile.Vault 1.0

Dialog {
    id: root

    property Vault vault
    property UnitListModel unitListModel

    property string retainedSnapshotName
    property var retainedSnapshotDateTime

    property int cloudAccountId
    property string memoryCardPath

    signal operationFinished(var successful)


    property int _retainedSnapshotPrevDisplayIndex: -1
    property bool _storageMenuOpen

    function _setRetainedSnapshotIndex(modelIndex) {
        if (modelIndex < 0 || modelIndex >= snapshotModel.count) {
            return
        }
        var data = snapshotModel.get(modelIndex)
        var retainedSnapshotDisplayIndex = 1
        if (_retainedSnapshotPrevDisplayIndex < 0) {
            retainedSnapshotName = data.name
            retainedSnapshotDateTime = data.timestamp
            _retainedSnapshotPrevDisplayIndex = data.snapshotIndex + 2

            // this is the first time this has been called, insert the dummy header entries
            snapshotModel.insert(0, {"header": "keep", "name": "", "timestamp": null, "notes": "", "snapshotIndex": -1})
            snapshotModel.insert(1, {"header": "delete", "name": "", "timestamp": null, "notes": "", "snapshotIndex": -1})

            snapshotModel.move(modelIndex + 2, 1, 1)
        } else if (modelIndex > 2) {        // not a header or the currently retained snapshot
            var returnIndex = _retainedSnapshotPrevDisplayIndex
            retainedSnapshotName = data.name
            retainedSnapshotDateTime = data.timestamp
            _retainedSnapshotPrevDisplayIndex = data.snapshotIndex + 2
            if (modelIndex > returnIndex) {
                returnIndex++
            }
            snapshotModel.move(modelIndex, retainedSnapshotDisplayIndex, 1)
            snapshotModel.move(retainedSnapshotDisplayIndex + 1, returnIndex, 1)
        }
    }

    canAccept: false
    acceptDestination: migrationProgressComponent

    Component {
        id: migrationProgressComponent

        BackupMigrationProgressPage {
            vault: root.vault
            unitListModel: root.unitListModel

            snapshotName: root.retainedSnapshotName
            snapshotDateTime: root.retainedSnapshotDateTime

            toCloudAccountId: root.cloudAccountId
            toBackupDir: root.memoryCardPath

            onButton1Clicked: {
                root.operationFinished(state == "success")
                if (state == "success") {
                    pageStack.pop(pageStack.previousPage(root))
                } else {
                    pageStack.pop(root)
                }
            }
        }
    }

    BackupUtils {
        id: backupUtils
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: contentColumn.height

        Column {
            id: contentColumn
            width: root.width

            DialogHeader {
                //: Major heading on the page which lets the user select which backup they wish to migrate to the new format.
                //% "Update your backup"
                title: qsTrId("vault-he-update_your_backup")
            }

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - x*2
                height: implicitHeight + Theme.paddingLarge
                wrapMode: Text.Wrap
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeSmall

                //: Descriptive label on the page which lets the user select which backup they wish to migrate to the new format, describing the semantics of the migration operation.
                //% "Backing up is now easier than ever. Before continuing, please select one of your previous backups as a starting point. The rest will be removed."
                text: qsTrId("vault-la-backup_migration_description")
            }

            add: Transition {
                enabled: root.status == PageStatus.Active
                SequentialAnimation {
                    PropertyAction { property: "opacity"; value: 0 }
                    PauseAnimation { duration: 200 }
                    NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 250; easing.type: Easing.InOutQuad }
                }
            }

            move: Transition {
                enabled: root.status == PageStatus.Active
                         && !_storageMenuOpen    // very hacky but prevents this animation when context menu opens
                NumberAnimation {
                    properties: "x,y"; duration: 400; easing.type: Easing.InOutQuad
                }
            }

            Repeater {
                model: ListModel {
                    id: snapshotModel

                    Component.onCompleted: {
                        var snapshots = root.vault.snapshots()
                        for (var i=0; i<snapshots.length; i++) {
                            var props = {
                                "header": "",
                                "name": snapshots[i],
                                "timestamp": backupUtils.dateTimeFromIsoString(snapshots[i]),
                                "notes": root.vault.notes(snapshots[i]).trim(),
                                "snapshotIndex": i
                            }
                            append(props)
                        }
                    }
                }

                // Theoretically should be able use ListView section headers instead of dynamically
                // loading different delegates with dummy entries but unfortunately headers don't
                // work correctly with ViewTransition animations. Also using Loader allows insertion
                // of the storage combo box above the 'delete these' header.
                delegate: Loader {
                    width: root.width
                    sourceComponent: {
                        if (model.header == "keep") {
                            return retainedSnapshotsHeaderComponent
                        } else if (model.header == "delete") {
                            return deletedSnapshotsHeaderComponent
                        }
                        return snapshotDelegateComponent
                    }
                    onLoaded: {
                        if (model.header.length == 0) {
                            item.displayName = Format.formatDate(model.timestamp, Format.DateLong)
                                    + " " + Format.formatDate(model.timestamp, Format.TimeValue)
                            item.notes = model.notes
                            item.modelIndex = Qt.binding(function() { return model.index })
                        }
                    }
                }
            }
        }

        VerticalScrollDecorator {}
    }

    Component {
        id: retainedSnapshotsHeaderComponent

        Item {
            width: root.width
            height: sectionHeader.height

            SectionHeader {
                id: sectionHeader

                //: Minor heading on the page which lets the user select which backup they wish to migrate to the new format.  Under this heading will be the (single) backup they migrate.
                //% "Keep this"
                text: qsTrId("vault-he-backup_migration_keep_this")
            }
        }
    }

    Component {
        id: deletedSnapshotsHeaderComponent

        Column {
            width: root.width

            BackupRestoreStoragePicker {
                backupMode: true

                //: Select whether backup data should be migrated to memory card or cloud storage
                //% "Update backup to"
                actionText: qsTrId("vault-la-update_backup_to")

                onMenuOpenChanged: root._storageMenuOpen = menuOpen
                onSelectionValidChanged: {
                    root.cloudAccountId = selectionValid ? cloudAccountId : 0
                    root.memoryCardPath = selectionValid ? memoryCardPath : ""
                    root.canAccept = selectionValid
                }
            }

            SectionHeader {
                // only show if there is more than one snapshot (exclude 2 dummy headers)
                visible: snapshotModel.count > 3

                //: Minor heading on the page which lets the user select which backup they wish to migrate to the new format.  Under this heading will be any backups to delete instead of migrating.
                //% "Delete these"
                text: qsTrId("vault-he-backup_migration_delete_these")
            }
        }
    }

    Component {
        id: snapshotDelegateComponent

        SnapshotListDelegate {
            width: parent.width

            onClicked: {
                root._setRetainedSnapshotIndex(modelIndex)
            }
        }
    }
}
