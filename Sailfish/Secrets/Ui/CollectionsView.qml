import QtQuick 2.2
import Sailfish.Silica 1.0
import Sailfish.Crypto 1.0
import Sailfish.Secrets 1.0 as Secrets
import Sailfish.Secrets.Ui 1.0

Column {
    id: collectionsView

    property QtObject cryptoManager
    property QtObject secretManager
    property string storagePluginName

    property alias collectionsCount: collectionsModel.count
    property alias collectionsPopulated: collectionsModel.populated

    function refreshCollections() {
        collectionsModel.refreshModelData()
    }

    spacing: Theme.paddingMedium

    Repeater {
        id: collectionsRepeater
        width: parent.width

        model: CollectionsModel {
            id: collectionsModel
            secretManager: collectionsView.secretManager
            storagePluginName: collectionsView.storagePluginName
        }

        delegate: CollectionDelegate {
            width: parent.width
            height: implicitHeight
            cryptoManager: collectionsView.cryptoManager
            secretManager: collectionsView.secretManager
            storagePluginName: collectionsView.storagePluginName
            collectionName: model.collectionName
            isCollectionLocked: model.isCollectionLocked
        }
    }
}
