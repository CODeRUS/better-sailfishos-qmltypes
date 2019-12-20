/*
 * Copyright (c) 2013 - 2019 Jolla Ltd.
 *
 * License: Proprietary
 */

import QtQuick 2.0
import Sailfish.Silica 1.0
import com.jolla.startupwizard 1.0
import org.nemomobile.systemsettings 1.0

Dialog {
    id: root

    signal clicked()

    property var _translations: []

    function _dummyForTranslations() {
        //% "Ahoy!"
        return qsTrId("startupwizard-la-ahoy")
    }

    StartupWizardManager {
        id: wizardManager
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: contentColumn.height

        Column {
            id: contentColumn
            x: Theme.horizontalPageMargin
            y: x
            width: root.width - x*2
            spacing: Theme.paddingMedium

            Repeater {
                model: LanguageModel {}

                Label {
                    width: contentColumn.width
                    font.pixelSize: Theme.fontSizeLarge
                    fontSizeMode: Text.Fit
                    color: wizardManager.defaultHighlightColor()
                    text: {
                        // Avoid showing blank text for now. Remove this when startupwizard-la-ahoy
                        // has been translated.
                        var s = wizardManager.translatedText("startupwizard-la-ahoy", model.locale)
                        if (s.length == 0) {
                            s = wizardManager.translatedText("startupwizard-la-ahoy_welcome", model.locale)
                        }
                        if (_translations.indexOf(s) > 0) {
                            return ""
                        }
                        _translations.push(s)
                        return s
                    }
                    visible: text != ""
                }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            root.clicked()
        }
    }
}
