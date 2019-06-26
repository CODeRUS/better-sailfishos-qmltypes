/****************************************************************************
**
** Copyright (C) 2013 Jolla Ltd.
** Contact: Raine Mäkeläinen <raine.makelainen@jollamobile.com>
**
****************************************************************************/

import QtQuick 2.0

ListModel {
    ListElement {
        //: No cropping
        //% "None"
        text: qsTrId("components_gallery-li-none")
        ratio: -1.0
        type: "none"
    }
    ListElement {
        //: Original aspect ratio
        //% "Original"
        text: qsTrId("components_gallery-li-aspect_ratio_original")
        ratio: 0.0
        type: "original"
    }
    ListElement {
        //: Square aspect ratio
        //% "Square"
        text: qsTrId("components_gallery-li-aspect_ratio_square")
        ratio: 1.0
        type: "square"
    }
    ListElement {
        //: Avatar aspect ratio
        //% "Avatar"
        text: qsTrId("components_gallery-li-aspect_ratio_avatar")
        ratio: 1.0 // separate this from square so that we can open people picker for avatars
        type: "avatar"
    }
    ListElement {
        //: ambience aspect ratio
        //% "Ambience"
        text: qsTrId("components_gallery-li-aspect_ratio_ambience")
        ratio: 1.0
        type: "Ambience"
    }
    ListElement {
        //: 3:4 aspect ratio
        //% "3:4"
        text: qsTrId("components_gallery-li-aspect_ratio_3_4")
        ratio: 0.75
        type: "3:4"
    }
    ListElement {
        //: 4:3 aspect ratio
        //% "4:3"
        text: qsTrId("components_gallery-li-aspect_ratio_4_3")
        ratio: 1.333
        type: "4:3"
    }
}
