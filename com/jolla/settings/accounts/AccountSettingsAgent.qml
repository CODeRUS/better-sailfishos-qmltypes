import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Accounts 1.0
import com.jolla.settings.accounts 1.0

/*
    This component is used to implement an account settings UI plugin.

    When the settings for this account need to be displayed, an instance of this component is created
    and the initialPage is pushed onto the page stack.

    The implementation must:

    1) Set the initialPage property (i.e. the first page in the account flow) to a page
    2) Emit accountDeletionRequested() signal and pop the page when the user wants to delete the
       account.

    The accountId property will automatically be set to the ID of the account to be displayed.
*/
Item {
    // Provided for convenience; these will be set to valid values on construction
    property int accountId
    property Provider accountProvider
    property AccountManager accountManager
    property string accountsHeaderText  // translated string; can be used as the page header title on this page.

    // Set this to true to delay the deletion of this instance after all of its pages have been popped
    // from the page stack.
    property bool delayDeletion

    property Page initialPage

    signal accountDeletionRequested()


    function _serviceTranslations() {
        //% "Calendar"
        QT_TRID_NOOP("components_accounts-la-sync_service_name_calendar")

        //% "Contacts"
        QT_TRID_NOOP("components_accounts-la-sync_service_name_contacts")

        //% "Images"
        QT_TRID_NOOP("components_accounts-la-sync_service_name_images")

        //: Content feeds and notifications
        //% "Feeds and notifications"
        QT_TRID_NOOP("components_accounts-la-sync_service_name_feeds_and_notifications")

        //: Content feeds and notifications for Twitter
        //% "Tweets and notifications"
        QT_TRID_NOOP("components_accounts-la-sync_service_name_tweets_and_notifications")

        //: Name of the "Email" service type for an account.
        //% "Email"
        QT_TRID_NOOP("components_accounts-la-service_name_email")

        //: Describes the effect of enabling the "email" service for a particular user account.
        //% "Allow apps to send and receive email with your %1 account."
        QT_TRID_NOOP("components_accounts-la-service_description_email")

        // Name of the "Instant Messaging" service type for an account.
        //% "Instant Messaging"
        QT_TRID_NOOP("components_accounts-la-service_name_im")

        //: Describes the effect of enabling the "Instant Messaging" service for a particular user account.
        //% "Allow apps to chat using your %1 IM account and change your online status."
        QT_TRID_NOOP("components_accounts-la-service_description_im")

        // Name of the "Microblogging" service type (e.g. Twitter updates) for an account.
        //% "Microblogging"
        QT_TRID_NOOP("components_accounts-la-service_name_microblogging")

        //: Describes the effect of enabling the "Microblogging" service for a particular user account (e.g. to enable apps to post Twitter updates).
        //% "Allow apps to post and read your %1 updates."
        QT_TRID_NOOP("components_accounts-la-service_description_microblogging")

        // Name of the "Sharing" service type for an account (enables photo sharing, video sharing, etc.)
        //% "Sharing"
        QT_TRID_NOOP("components_accounts-la-service_name_sharing")

        //: Describes the effect of enabling the "Sharing" service for a particular user account.
        //% "Allow apps to show and update your %1 photos, videos and other content."
        QT_TRID_NOOP("components_accounts-la-service_description_sharing")

        //: Name of the "Storage" service type for an account (enables cloud storage and backup from the device)
        //% "Storage"
        QT_TRID_NOOP("components_accounts-la-service_name_storage")

        //: Describes the effect of enabling the "Storage" service for a particular user account.
        //% "Allow apps to backup or otherwise store data to the %1 cloud"
        QT_TRID_NOOP("components_accounts-la-service_description_storage")

        //: Notifications
        //% "Notifications"
        QT_TRID_NOOP("components_accounts-la-sync_service_name_notifications")

        //: More precise name for cloud storage services
        //% "Cloud storage"
        QT_TRID_NOOP("components_accounts-la-service_name_cloud_storage")
    }

    FirstTimeUseCounter {
        id: firstTimeUseCounter
        limit: 3
        defaultValue: 1 // display hint twice for existing users
        key: "/sailfish/accounts/settings_autosave_hint_count"

        onActiveChanged: {
            if (active) {
                var comp = Qt.createComponent("AccountSettingsSaveHint.qml")
                if (comp.status == Component.Ready) {
                    var obj = comp.createObject(initialPage)
                    obj.hintShownChanged.connect(function() {
                        if (obj.hintShown) {
                            firstTimeUseCounter.increase()
                        }
                    })
                }
            }
        }
    }

    AccountFactory {
        id: accountFactory
    }

    Component.onCompleted: accountFactory.ensureAccountSyncProfiles(accountId)
}
