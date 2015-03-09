/****************************************************************************
**
** Copyright (C) 2013 Jolla Ltd.
** Contact: Raine Makelainen <raine.makelainen@jolla.com>
**
****************************************************************************/

import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Email 1.1
import org.nemomobile.dbus 1.0
import org.nemomobile.configuration 1.0

Page {
    id: messageComposer

    property ListModel attachmentsModel: tmpAttachmentFiles
    property string emailSubject
    property var emailTo
    property var emailCc
    property var emailBcc
    property string emailBody
    property int messageId

    property string action
    property int originalMessageId
    property int accountId

    property bool _emailInstalled

    _clickablePageIndicators: !(isLandscape && emailComposer.item && emailComposer.item.toFieldHasFocus)

    DBusInterface {
        id: storeInterface

        destination: "com.jolla.jollastore"
        path: "/StoreClient"
        iface: "com.jolla.jollastore"

        function openStoreEmail() {
            call("showApp", ["jolla-email"])
            pageStack.pop()
        }
    }

    ListModel {
        id: tmpAttachmentFiles
    }

    SilicaFlickable {
        anchors.fill: parent
        visible: placeholder.enabled
        interactive: visible
        ViewPlaceholder {
            id: placeholder
            //: Email application is not installed, user should be guided to Jolla store for installing it.
            //% "Install Jolla Email from Store."
            text: qsTrId("components_email-la-install-email-application-from-store")

            //: "Placeholder hint text to guide user to trigger email application install from store"
            //% "Pull down to install"
            hintText: qsTrId("components_email-la-pulldown-to-install-email-application")
            enabled: emailComposer.status === Loader.Error || !_emailInstalled
        }

        PullDownMenu {
            MenuItem {

                //: "Pull down menu item to install email application from store"
                //% "Install Jolla Email"
                text: qsTrId("components_email-me-install-email-application")
                onClicked: storeInterface.openStoreEmail()
            }
        }
    }

    Loader {
        id: emailComposer
        anchors.fill: parent
        visible: _emailInstalled
        property bool loaderCompleted

        onLoaded: {
            messageComposer.attachmentsModel = Qt.binding(function() { return item.attachmentsModel })
            //append any existent temp attachments
            for (var i = 0; i < tmpAttachmentFiles.count; ++i) {
                messageComposer.attachmentsModel.append(tmpAttachmentFiles.get(i))
            }
        }

        function loadComposer(version) {
            if (!loaderCompleted) {
                return
            } else if (version === "1.1") {
                _emailInstalled = true
                emailComposer.setSource("EmailComposerComponent.1.1.qml",
                                        {
                                            "emailSubject": emailSubject,
                                            "emailTo": emailTo,
                                            "emailCc": emailCc,
                                            "emailBcc": emailBcc,
                                            "emailBody": emailBody,
                                            "messageId": messageId,
                                            "action": action,
                                            "originalMessageId": originalMessageId,
                                            "accountId": accountId
                                        })
            } else {
                _emailInstalled = false
            }
        }

        Component.onCompleted: {
            loaderCompleted = true
            if (ImportChecker.hasImportComponent) {
                loadComposer("1.1")
            } else {
                loadComposer(emailInstalled.value)
            }
        }
    }

    ConfigurationValue {
        id: emailInstalled

        key: "/apps/jolla-email/version"
        defaultValue: "1.0"

        // For case of uninstall and install back so that
        // application using this was not closed in between.
        onValueChanged: emailComposer.loadComposer(value)
    }
}
