import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Contacts 1.0
import org.nemomobile.contacts 1.0

ContactSelectPage {
    id: pickerPage

    signal selectedRecipients(variant contacts)

    function clearSelections() {
        selectionModel.clear()
    }

    onContactClicked: {
        var formattedName = Format._joinNames(contact.primaryName, contact.secondaryName)
        var props = { "person": contact,
                      "formattedNameText": formattedName,
                      "property": property,
                      "propertyType": propertyType }
        selectionModel.append(props)
        pickerPage.selectedRecipients(selectionModel)
        pageStack.pop()
    }

    ListModel {
        id: selectionModel
    }
}
