import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Accounts 1.0

/*
    This component is used to implement an account credentials update UI plugin.

    When the credentials for this account needs to be updated, an instance of this component is created
    and the initialPage is pushed onto the page stack.

    The implementation must:

    1) Set the initialPage property (i.e. the first page in the account flow) to a page
    2) Ensure the page that follows the last account credentials update page is the provided
       endDestination
    3) Emit credentialsUpdated() or credentialsUpdateError() when the credentials update operation
       completes

    The accountId property will automatically be set to the ID of the account to be updated.
*/
Item {
    // Provided for convenience; these will be set to valid values on construction
    property int accountId
    property string userName
    property Provider accountProvider
    property AccountManager accountManager

    // When the account update flow completes, set the following page to this endDestination.
    // If the last displayed page is a dialog, set its acceptDestination* properties to these
    // endDestination* values; otherwise, if it is a page, you can call goToEndDestination()
    // to move forward.
    property var endDestination
    property int endDestinationAction
    property var endDestinationProperties: ({})
    property var endDestinationReplaceTarget

    property Page initialPage

    // Set this to true to delay the deletion of this instance after all of its pages have been popped
    // from the page stack.
    property bool delayDeletion

    // Set to true if the update action is non-destructive and can be cancelled. E.g. this is false
    // for OAuth updates through AccountFactory, as that destroys existing credentials before
    // displaying the authentication page to accept new credentials, so the account should left in
    // a "not signed in" state if the user does not enter new credentials.
    property bool canCancelUpdate

    signal credentialsUpdated(int updatedAccountId)
    signal credentialsUpdateError(string errorMessage)

    function goToEndDestination() {
        switch (endDestinationAction) {
        case PageStackAction.Push:
            pageStack.animatorPush(endDestination, endDestinationProperties)
            break
        case PageStackAction.Pop:
            pageStack.pop(endDestination)
            break
        case PageStackAction.Replace:
            if (endDestinationReplaceTarget === undefined) {    // use === as target=null is still valid for replaceAbove()
                pageStack.animatorReplace(endDestination, endDestinationProperties)
            } else {
                pageStack.animatorReplaceAbove(endDestinationReplaceTarget, endDestination, endDestinationProperties)
            }
            break
        }
    }
}
