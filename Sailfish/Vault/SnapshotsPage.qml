
import QtQuick 2.2
import Sailfish.Silica 1.0
import Sailfish.Vault 1.0
import NemoMobile.Vault 1.0
import QtDocGallery 5.0

Page {
    id: root
    property alias model: selectionModel.docModel
    signal itemsSelected(variant items)

    function deleteClicked()
    {
        // Store selected items to the array
        var array = []
        for (var index = 0; index < selectionModel.count; index++) {
            if (selectionModel.get(index).selected) {
                array.push(selectionModel.get(index).name)
            }
        }

        // Emit signal with selected items, to indicate that selection is done
        itemsSelected(array)
    }


    // A proxy model for hiding the SnapshotList model and to provide selection role for
    // each item. This model also takes care of if items are removed or added in the background
    // while this Page is active to keep the content up-to-date.
    QtObject {
        id: selectionModel
        property bool ready
        property int count: model.count
        property int selectionCount: 0
        property ListModel model: ListModel {}
        property QtObject docModel
        property bool active: root.status === PageStatus.Active || root.status === PageStatus.Activating

        // Make sure not to call _update() when this page is not active anymore
        onActiveChanged: if (!active) docModel.countChanged.disconnect(_update)

        function get(index)
        {
            return model.get(index)
        }

        function selectOrClearAll(select)
        {
            for (var i=0; i < docModel.count; i++) {
                model.setProperty(i, "selected", select)
            }

            selectionCount = select ? count : 0
        }

        function setSelected(index, selected)
        {
            if (model.get(index).selected == selected)
                return

            model.setProperty(index, "selected", selected)

            if (selected) {
                ++selectionCount
            } else {
                --selectionCount
            }
        }

        function _update()
        {
            if (active && docModel == null) {
                return
            }

            // First time initialization
            if (!ready) {
                for(var i=0; i < docModel.count; i++) {
                    model.insert(i, {"name": docModel.get(i).name, "note": docModel.get(i).note, "selected": false})
                }
                ready = true
                docModel.countChanged.connect(_update)
            }

            // Snapshots removed from the document model
            if (model.count > docModel.count) {
                for (var i = 0; i < model.count; i++) {
                    var name = model.get(i).name
                    var found = false
                    for (var j = 0; j < docModel.count; j++) {
                        if (name == docModel.get(j).name) {
                            found = true
                            break
                        }
                    }

                    // Item is not in the SnapshotsList model anymore,
                    // so let's remove it.
                    if (!found) {
                        model.remove(i)
                        i--;
                    }
                }
            }

            // Snapshots have been added
            if (model.count < docModel.count) {
                for (var i = 0; i < docModel.count; i++) {
                    var name = docModel.get(i).name
                    var found = false
                    for (var j = 0; j < model.count; j++) {
                        if (name == model.get(j).name) {
                            found = true
                            break
                        }
                    }

                    // New item, let's add it to the model
                    if (!found) {
                        if (i < model.count) {
                            model.insert(i, {"name": docModel.get(i).name, "note": docModel.get(i).note, "selected": false})
                        } else {
                            model.append({"name": docModel.get(i).name, "note": docModel.get(i).note, "selected": false})
                        }
                    }

                }
            }
        }

        onDocModelChanged: if (docModel !== null) _update()
    }

    SilicaListView {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: controlPanel.top
        clip: true
        model: selectionModel.ready ? selectionModel.model : null
        header: PageHeader {
            //% "Select snapshots"
            title: qsTrId("vault-he-select-snapshots")
        }

        delegate: SnapshotItem {
            onClicked: selectionModel.setSelected(index, !model.selected)
            highlighted: model.selected
        }

        PullDownMenu {
            MenuItem {
                //% "Clear All"
                text: qsTrId("vault-me-clear-selections")
                onClicked: selectionModel.selectOrClearAll(false)
                visible: selectionModel.selectionCount > 0
            }

            MenuItem {
                //% "Select All"
                text: qsTrId("vault-me-select-all")
                onClicked: selectionModel.selectOrClearAll(true)
                visible: selectionModel.count !== selectionModel.selectionCount
            }
        }

        VerticalScrollDecorator { }
    }

    DockedPanel {
        id: controlPanel
        width: parent.width
        height: Theme.itemSizeLarge
        dock: Dock.Bottom
        open: selectionModel.selectionCount > 0

        Image {
            anchors.fill: parent
            fillMode: Image.PreserveAspectFit
            source: "image://theme/graphic-gradient-edge"
        }

        IconButton {
            icon.source: "image://theme/icon-m-delete"
            anchors.centerIn: parent
            onClicked: root.deleteClicked()
        }
    }
}
