import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Contacts 1.0
import org.nemomobile.contacts 1.0

ContactsMultiSelectDialog {
    id: pickerDialog

    signal selectedRecipients(variant contacts)

    function clearSelections() {
        selectedContacts.clear()
    }

    acceptDestinationAction: PageStackAction.Pop
    // TODO pending contacts picker support:
    // dont allow selection of dups
    // deselect contacts removed from email editor
    onDone: {
        if (result == DialogResult.Accepted) {
            pickerDialog.selectedRecipients(selectedContacts)
        }
    }
}
