import QtQuick 2.2
import Sailfish.Silica 1.0
import Sailfish.Crypto 1.0 as Crypto
import Sailfish.Secrets 1.0 as Secrets
import Sailfish.Secrets.Ui 1.0

Column {
    id: collectionDelegate

    property alias cryptoManager: collectionKeysView.cryptoManager
    property alias secretManager: collectionKeysView.secretManager
    property alias storagePluginName: collectionKeysView.storagePluginName
    property alias collectionName: collectionKeysView.collectionName
    property bool isCollectionLocked

    property bool _isGnuPGImportCollection: (storagePluginName.indexOf("gnupg") >= 0 || storagePluginName.indexOf("smime") >= 0) && collectionName == "import"
    visible: !_isGnuPGImportCollection

    BackgroundItem {
        id: backgroundItem
        height: Math.max(collectionNameLabel.height, collectionLockedIcon.height)
        enabled: isCollectionLocked

        SectionHeader {
            id: collectionNameLabel
            text: collectionName
            anchors.verticalCenter: parent.verticalCenter
            width: isCollectionLocked ? parent.width - collectionLockedIcon.width - 2*x - Theme.paddingMedium
                                      : parent.width - 2*x

            color: backgroundItem.highlighted || !isCollectionLocked ? Theme.highlightColor : Theme.primaryColor
            wrapMode: Text.Wrap

            horizontalAlignment: isCollectionLocked ? Text.AlignLeft : Text.AlignRight
        }

        Image {
            id: collectionLockedIcon

            opacity: collectionDelegate.isCollectionLocked ? 1.0 : 0.0
            Behavior on opacity { FadeAnimation {} }
            visible: opacity > 0.0
            anchors.verticalCenter: parent.verticalCenter
            anchors {
                right: parent.right
                rightMargin: Theme.horizontalPageMargin
            }
            source: "image://theme/icon-s-secure?" + (backgroundItem.highlighted ? Theme.highlightColor : Theme.primaryColor)
        }

        onClicked: {
            if (collectionDelegate.isCollectionLocked) {
                collectionKeysView.requestKeysFromCollection()
            }
        }
    }

    CollectionKeysView {
        id: collectionKeysView
        width: parent.width
        visible: !collectionDelegate.isCollectionLocked
        onCollectionKeysRequestCompleted: {
            if (errorCode == 0) {
                // even if the collection uses access-relock semantics
                // we show it as unlocked as we were able to retrieve
                // the key identifiers from the collection.
                collectionDelegate.isCollectionLocked = false
            }
        }
    }
}
