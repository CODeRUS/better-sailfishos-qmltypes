import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Contacts 1.0
import MeeGo.QOfono 0.2

Page {
    id: root

    property string importSourceUrl
    property string importSourceModemPath

    signal contactOpenRequested(var contactId)

    //=== internal/private members follow

    property string _fileName
    property bool _fileImport: _fileName != ''
    property int _readCount
    property int _savedCount
    property bool _error
    property var _importedContactId
    property bool _simImportStarted

    onStatusChanged: {
        if (status === PageStatus.Deactivating) {
            versitImport.cancel()
        }
    }

    Component.onCompleted: {
        if (importSourceUrl != "") {
            busyIndicator.running = true
            versitImport.importContacts(importSourceUrl)
            var index = importSourceUrl.lastIndexOf("/")
            _fileName = decodeURIComponent(index >= 0 ? importSourceUrl.substring(index+1) : importSourceUrl)
        } else if (importSourceModemPath != "") {
            busyIndicator.running = true
            // This beginImport() call won't actually do anything if
            // OfonoPhonebook isn't ready yet. In that case we actually
            // start the import in OfonoPhonebook.onValidChanged handler.
            // The _simImportStarted property ensures that we don't start
            // the import more than once.
            ofonoPhonebook.beginImport()
        }
    }

    function _statusText() {
        if (busyIndicator.running) {            
            if (_fileImport) {
                //: Importing contacts from a specified file
                //% "Importing contacts from %1..."
                return qsTrId("components_contacts-la-importing_contacts_from_file").arg(_fileName)
            } else {
                //: Importing contacts from SIM
                //% "Importing contacts from SIM card..."
                return qsTrId("components_contacts-la-importing_contacts_from_sim")
            }
        } else if (_error) {
            if (_fileImport) {
                //: Error while importing contacts from the specified file
                //% "Unable to import contacts from %1."
                return qsTrId("components_contacts-la-failed_to_import_contacts_file").arg(_fileName)
            } else {
                //: Error while importing contacts from SIM
                //% "Unable to import contacts from SIM card."
                return qsTrId("components_contacts-la-failed_to_import_contacts_sim")
            }
        } else if (_savedCount > 0) {
            //% "Imported %n new contact(s)."
            return qsTrId("contacts_settings-la-imported_n_contacts", _savedCount)
        } else if (_readCount > 0 && _savedCount == 0) {
            //% "No new contacts to import."
            return qsTrId("contacts_settings-la-no_new_contacts")
        } else {
            //% "Contacts imported."
            return qsTrId("components_contacts-la-contacts_imported")
        }
    }

    Column {
        x: Theme.paddingLarge
        width: parent.width - x*2

        PageHeader {
            // no text set, used for spacing only
        }

        Label {
            width: parent.width
            height: implicitHeight + Theme.paddingLarge
            color: Theme.highlightColor
            font.pixelSize: Theme.fontSizeExtraLarge
            wrapMode: Text.Wrap

            //% "Import contacts"
            text: qsTrId("components_contacts-he-import_contacts")
        }

        Label {
            width: parent.width
            color: Theme.secondaryHighlightColor
            visible: root._readCount > 0
            wrapMode: Text.Wrap

                                     //: When importing contacts from a file, this describes the number of contacts found
                                     //% "%n contact(s) found in %1."
            text: root._fileImport ? qsTrId("contacts_settings-la-found_n_contacts_file", root._readCount).arg(root._fileName)
                                     //: When importing contacts from SIM, this describes the number of contacts found
                                     //% "%n contact(s) found on SIM card."
                                   : qsTrId("contacts_settings-la-found_n_contacts_sim", root._readCount)
        }

        Label {
            width: parent.width
            height: implicitHeight + Theme.paddingLarge
            color: Theme.secondaryHighlightColor
            wrapMode: Text.Wrap
            text: root._statusText()
        }

        BusyIndicator {
            id: busyIndicator
            anchors.horizontalCenter: parent.horizontalCenter
            size: BusyIndicatorSize.Large
        }
    }

    Button {
        anchors {
            bottom: parent.bottom
            bottomMargin: Theme.paddingLarge
            horizontalCenter: parent.horizontalCenter
        }
        opacity: (busyIndicator.running || root._error) ? 0 : 1
        Behavior on opacity { FadeAnimation {} }

        text: root._importedContactId != undefined
                //% "View contact"
              ? qsTrId("components_contacts-la-view_contact")
                //% "View all contacts"
              : qsTrId("components_contacts-la-view_all_contact")

        onClicked: {
            root.contactOpenRequested(root._importedContactId)
        }
    }

    ContactImporter {
        id: versitImport
        onImportFinished: {
            root._readCount = readCount
            root._savedCount = savedCount
            if (savedCount == 1) {
                fetchFirstSavedContact()
            } else {
                busyIndicator.running = false
            }
        }
        onImportFailed: {
            busyIndicator.running = false
            root._error = true
        }
        onFetchFirstSavedContactFinished: {
            root._importedContactId = firstSavedContactId
            busyIndicator.running = false
        }
        onFetchFirstSavedContactFailed: {
            busyIndicator.running = false
        }
    }

    OfonoPhonebook {
        id: ofonoPhonebook
        modemPath: root.importSourceModemPath
        onImportingChanged: if (importing) _simImportStarted = true
        onValidChanged: if (valid && !_simImportStarted) ofonoPhonebook.beginImport()
        onImportReady: {
            versitImport.importContactsData(vcardData)
        }
        onImportFailed: {
            busyIndicator.running = false
            root._error = true
        }
    }
}
