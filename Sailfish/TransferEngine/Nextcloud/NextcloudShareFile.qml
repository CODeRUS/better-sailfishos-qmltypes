/****************************************************************************************
**
** Copyright (C) 2019 Open Mobile Platform LLC
** All rights reserved.
**
** License: Proprietary.
**
****************************************************************************************/
import QtQuick 2.6
import Sailfish.Silica 1.0
import Sailfish.TransferEngine 1.0
import Sailfish.TransferEngine.Nextcloud 1.0 // for translations

ShareFilePreviewDialog {
    id: root

    imageScaleVisible: false
    descriptionVisible: false
    metaDataSwitchVisible: false

    remoteDirName: fileInfo.mimeFileType == "image"
                     //: Target folder in Nextcloud. Nextcloud has a special folder called Photos
                     //: where images are uploaded. Localization should match that.
                     //% "Photos"
                   ? qsTrId("webshare-la-nextcloud-uploads-images")
                     //: Target folder in Nextcloud. Nextcloud has a special folder called Documents
                     //: where files other than images are uploaded. Localization should match that.
                     //% "Documents"
                   : qsTrId("webshare-la-nextcloud-uploads-documents")

    onAccepted: {
        shareItem.start()
    }
}

