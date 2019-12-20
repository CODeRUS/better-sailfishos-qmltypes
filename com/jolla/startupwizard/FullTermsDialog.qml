/*
 * Copyright (c) 2018 - 2019 Jolla Ltd.
 *
 * License: Proprietary
 */

import QtQuick 2.0
import Sailfish.Silica 1.0
import com.jolla.startupwizard 1.0

Dialog {
    id: fullTermsDialog

    property alias headingText: header.title
    property alias bodyText: bodyTextLabel.text
    property alias bodyTextColor: bodyTextLabel.color

    forwardNavigation: false

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: header.height + termsTextColumn.height + (Theme.paddingLarge * 2)

        WizardDialogHeader {
            id: header
            acceptText: ""
        }

        Column {
            id: termsTextColumn
            anchors {
                top: header.bottom
                left: parent.left
                leftMargin: Theme.horizontalPageMargin
                right: parent.right
                rightMargin: Theme.horizontalPageMargin
            }
            spacing: Theme.paddingLarge

            Label {
                id: bodyTextLabel
                width: parent.width
                wrapMode: Text.Wrap
                font.pixelSize: Theme.fontSizeExtraSmall
                color: Theme.highlightColor
            }
        }

        VerticalScrollDecorator {}
    }
}
