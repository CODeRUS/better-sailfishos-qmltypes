/*
 * Copyright (c) 2015 - 2019 Jolla Ltd.
 *
 * License: Proprietary
 */

import QtQuick 2.0
import Sailfish.Silica 1.0
import com.jolla.startupwizard 1.0
import org.nemomobile.systemsettings 1.0

Dialog {
    id: root

    property string locale
    property string language
    property alias model: languageList.model
    property StartupWizardManager startupWizardManager

    signal localeClicked()

    SilicaListView {
        id: languageList
        anchors.fill: parent
        header: WizardDialogHeader {
            id: dialogHeader
            // We don't have access to DialogHeader's internal label to animate it, so
            // overlay our own 'Accept' label and blink that instead.
            property Label fakeAcceptLabel: actualLabel
            function animateText() {
                acceptTextBlink.restart()
            }
            acceptText: root.canAccept ? " " : ""   // set to non-empty when it should be pressable, to enable highlight effect
            cancelText: ""

            Label {
                id: actualLabel
                anchors {
                    right: parent.right
                    rightMargin: Theme.horizontalPageMargin
                    verticalCenter: parent.verticalCenter
                }
                opacity: 0
                font.pixelSize: Theme.fontSizeLarge
                font.family: Theme.fontFamilyHeading
                text: dialogHeader.nextPageText
            }
            SequentialAnimation {
                id: acceptTextBlink
                FadeAnimation {
                    target: languageList.headerItem.fakeAcceptLabel
                    from: 0
                    to: 1
                    duration: 250
                }
                PauseAnimation { duration: 500 }
                SequentialAnimation {
                    loops: Animation.Infinite
                    FadeAnimation {
                        target: languageList.headerItem.fakeAcceptLabel
                        from: 1
                        to: 0
                        duration: 2000
                    }
                    FadeAnimation {
                        target: languageList.headerItem.fakeAcceptLabel
                        from: 0
                        to: 1
                        duration: 2000
                    }
                }
            }
        }

        delegate: ListItem {
            id: delegateItem
            width: root.width
            highlighted: down || root.locale === model.locale

            onClicked: {
                languageList.headerItem.fakeAcceptLabel.text = wizardManager.translatedText("startupwizard-he-next_page", locale)
                languageList.headerItem.animateText()

                // Avoid showing blank text for now. Remove this when startupwizard-he-next_page
                // has been translated.
                if (languageList.headerItem.fakeAcceptLabel.text.length == 0) {
                    //% "Accept"
                    var translatedText = qsTrId("startupwizard-he-dialog_accept")
                    languageList.headerItem.fakeAcceptLabel.text = wizardManager.translatedText("startupwizard-he-dialog_accept", locale)
                }

                root.locale = model.locale
                root.language = model.name
                root.localeClicked()
            }

            Label {
                x: Theme.horizontalPageMargin
                anchors.verticalCenter: parent.verticalCenter
                width: root.width - x*2
                text: model.name
                color: delegateItem.highlighted
                       ? startupWizardManager.defaultHighlightColor()
                       : startupWizardManager.defaultPrimaryColor()
            }
        }

        VerticalScrollDecorator {}
    }
}
