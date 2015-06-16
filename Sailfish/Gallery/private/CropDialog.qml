/****************************************************************************
**
** Copyright (C) 2013 Jolla Ltd.
** Contact: Raine Mäkeläinen <raine.makelainen@jollamobile.com>
**
****************************************************************************/

import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Gallery 1.0

SplitViewDialog {
    id: aspectRatioDialog

    property bool avatarCrop

    property alias foregroundItem: flickable
    property alias foreground: flickable.children

    signal edited
    signal cropRequested
    signal cropCanceled

    onDone: {
        if (result == DialogResult.Accepted) {
            cropRequested()
        } else {
            cropCanceled()
        }
    }

    background: SilicaListView {
        anchors.fill: parent

        header: DialogHeader {
            dialog: aspectRatioDialog
        }

        delegate: LabelItem {
            text: model.text
            //: Label that is shown for currently selected aspect ratio.
            //% "Aspect ratio"
            sectionLabel: qsTrId("components_gallery-li-aspect_ratio")
            selected: imageEditPreview.aspectRatioType == model.type

            onClicked: {
                aspectRatioDialog.splitOpen = !aspectRatioDialog.splitOpen
                imageEditPreview.aspectRatio = model.ratio
                imageEditPreview.aspectRatioType = model.type
            }
        }

        model: AspectRatioModel {}
    }

    _foreground: Flickable {
        id: flickable
        anchors.fill: parent
        flickableDirection: aspectRatioDialog.splitOpen ? Flickable.AutoFlickDirection : Flickable.HorizontalAndVerticalFlick
    }

    Binding {
        target: pageStack._pageStackIndicator
        property: "enabled"
        value: aspectRatioDialog.splitOpened
        when: aspectRatioDialog.status === PageStatus.Activating || aspectRatioDialog.status === PageStatus.Active
    }
}
