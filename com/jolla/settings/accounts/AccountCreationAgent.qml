import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Accounts 1.0
import com.jolla.settings.accounts 1.0

/*
    This component is used to implement an account creation UI plugin.

    When the user chooses to create this type of account, an instance of this component is created
    and the initialPage is pushed onto the page stack.

    The implementation must:

    1) Set the initialPage property (i.e. the first page in the account flow) to a Page or Dialog
    2) Ensure the page that follows the last account creation page is the provided endDestination.


    For example, a typical implementation of a UI flow would be:

    1) Set initialPage to be a Dialog that allows the user to enter username and password details
    2) When the dialog is accepted, show a page with a busy-spinner animation while creating the
       account asynchronously in the background. (AccountBusyPage.qml can be used for this purpose.)

       - If the account is created, show the account settings dialog to allow the user to confirm
         or customize particular settings. (AccountSettingsDialog.qml can be used for this
         purpose.)
             When the settings dialog is accepted, save the updated settings and move onto the
         endDestination. If the save operation is asynchronous, set delayDeletion=true until the save
         is done (or fails) to prevent the agent instance from being deleted until the operation
         completes.

       - If the account cannot be created, allow the user to go back to try again, or move onto the
         endDestination if the retry action is not possible.


    A note about object lifetimes:

        This agent instance is automatically destroyed when its pages have been removed from the
        page stack, unless delayDeletion=true, in which case the destroy operation is delayed until
        delayDeletion=false.

        Thus, if any object has to be kept alive for the duration of the account creation process,
        parent to the agent instance. For example, if the account settings are saved asynchronously,
        push the settings page as an instance parented to the agent, rather than as a component, so
        that the page stack does not automatically delete the page when it is popped from the stack
        and thus cut short the asynchronous save operation.
*/
Item {
    // Set this to the first page to be displayed
    property QtObject initialPage

    // Set to true to delay the deletion of this instance after moving to endDestination or popping
    // the creation page(s) from the stack.
    property bool delayDeletion

    // Provided for convenience; these will be set to valid values on construction
    property AccountManager accountManager
    property Provider accountProvider   // the provider for this account

    // When the account creation flow completes, set the following page to this endDestination.
    // If the last displayed page is a dialog, set its acceptDestination* properties to these
    // endDestination* values; otherwise, if it is a page, you can call goToEndDestination()
    // to move forward.
    property var endDestination
    property int endDestinationAction
    property var endDestinationProperties: ({})
    property var endDestinationReplaceTarget

    signal accountCreated(int accountId)
    signal accountCreationError(string errorMessage)

    function goToEndDestination() {
        switch (endDestinationAction) {
        case PageStackAction.Push:
            pageStack.push(endDestination, endDestinationProperties)
            break
        case PageStackAction.Pop:
            pageStack.pop(endDestination)
            break
        case PageStackAction.Replace:
            if (endDestinationReplaceTarget === undefined) {    // use === as target=null is still valid for replaceAbove()
                pageStack.replace(endDestination, endDestinationProperties)
            } else {
                pageStack.replaceAbove(endDestinationReplaceTarget, endDestination, endDestinationProperties)
            }
            break
        }
    }
}
