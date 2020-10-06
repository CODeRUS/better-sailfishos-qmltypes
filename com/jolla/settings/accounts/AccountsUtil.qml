/*
 * Copyright (c) 2013 - 2020 Jolla Ltd.
 * Copyright (c) 2020 Open Mobile Platform LLC.
 *
 * License: Proprietary
 */

pragma Singleton
import QtQml 2.2
import com.jolla.settings.accounts 1.0

QtObject {
    function serviceDisplayNameForService(service) {
        var s = serviceDisplayName(service.name, service.displayName)
        if (s.length === 0) {
            s = serviceDisplayNameFromType(service.serviceType, service.displayName)
        }
        return s
    }

    function serviceDisplayName(serviceName, serviceDisplayName) {
        switch (serviceName) {
        case "google-calendars":
        case "facebook-calendars":
        case "vk-calendars":
            return serviceDisplayNameFromType("caldav", serviceDisplayName)
        case "google-contacts":
        case "facebook-contacts":
        case "vk-contacts":
            return serviceDisplayNameFromType("carddav", serviceDisplayName)
        case "facebook-images":
        case "onedrive-images":
        case "dropbox-images":
        case "vk-images":
        case "nextcloud-images":
            return serviceDisplayNameFromType("images", serviceDisplayName)
        case "onedrive-backup":
        case "dropbox-backup":
            return serviceDisplayNameFromType("storage", serviceDisplayName)
        case "facebook-microblog":
        case "nextcloud-posts":
            //% "Notifications"
            return qsTrId("components_accounts-la-sync_service_name_notifications")
        case "twitter-microblog":
            //: Content feeds and notifications for Twitter
            //% "Tweets and notifications"
            return qsTrId("components_accounts-la-sync_service_name_tweets_and_notifications")
        case "google-gmail":
        case "email":
            return serviceDisplayNameFromType("e-mail", serviceDisplayName)
        case "vk-microblog":
        case "vk-microblog":
            //% "Feeds and notifications"
            return qsTrId("components_accounts-la-sync_service_name_feeds_and_notifications")
        case "nextcloud-backup":
            //% "Backup"
            return qsTrId("components_accounts-la-sync_service_backup")
        }
        return ""
    }

    function serviceDisplayNameFromType(serviceType, serviceDisplayName) {
        switch (serviceType) {
        case "caldav":
            //% "Calendar"
            return qsTrId("components_accounts-la-sync_service_name_calendar")
        case "carddav":
            //% "Contacts"
            return qsTrId("components_accounts-la-sync_service_name_contacts")
        case "e-mail":
            //% "Email"
            return qsTrId("components_accounts-la-service_name_email")
        case "images":
            //% "Images"
            return qsTrId("components_accounts-la-sync_service_name_images")
        case "IM":
            // Name of the "Instant Messaging" service type for an account.
            //% "Instant Messaging"
            return qsTrId("components_accounts-la-service_name_im")
        case "microblogging":
            // Name of the "Microblogging" service type (e.g. Twitter updates) for an account.
            //% "Microblogging"
            return qsTrId("components_accounts-la-service_name_microblogging")
        case "sharing":
            // Name of the "Sharing" service type for an account (enables photo sharing, video sharing, etc.)
            //% "Sharing"
            return qsTrId("components_accounts-la-service_name_sharing")
        case "storage":
            //: Name of the "Storage" service type for an account (enables cloud storage and backup from the device)
            //% "Storage"
            return qsTrId("components_accounts-la-service_name_storage")
        default:
            return serviceDisplayName
        }
    }

    function serviceDescription(service, providerDisplayName, providerName) {
        switch (service.serviceType) {
        case "caldav":
            //: Describes the effect of enabling the "Calendar" service for a particular user account.
            //% "Allow apps to show and upload your calendar events using the CalDAV protocol."
            return qsTrId("components_accounts-la-service_description_caldav")
        case "carddav":
            //: Describes the effect of enabling the "Contacts" service for a particular user account.
            //% "Allow apps to show and upload your contacts using the CardDAV protocol."
            return qsTrId("components_accounts-la-service_description_carddav")
        case "e-mail":
            //: Describes the effect of enabling the "email" service for a particular user account.
            //% "Allow apps to send and receive email with your %1 account."
            return qsTrId("components_accounts-la-service_description_email").arg(providerDisplayName)
        case "IM":
            //: Describes the effect of enabling the "Instant Messaging" service for a particular user account.
            //% "Allow apps to chat using your %1 IM account and change your online status."
            return qsTrId("components_accounts-la-service_description_im").arg(providerDisplayName)
        case "microblogging":
            //: Describes the effect of enabling the "Microblogging" service for a particular user account (e.g. to enable apps to post Twitter updates).
            //% "Allow apps to post and read your %1 updates."
            return qsTrId("components_accounts-la-service_description_microblogging").arg(providerDisplayName)
        case "sharing":
            //: Describes the effect of enabling the "Sharing" service for a particular user account.
            //% "Allow apps to show and update your %1 photos, videos and other content."
            return qsTrId("components_accounts-la-service_description_sharing").arg(providerDisplayName)
        case "storage":
            //: Describes the effect of enabling the "Storage" service for a particular user account.
            //% "Allow apps to backup or otherwise store data to the %1 cloud."
            return qsTrId("components_accounts-la-service_description_storage").arg(providerDisplayName)
        default:
            break
        }

        if (service.name.search("-images$") >= 0) {
            //: Describes the effect of enabling the "Images" service for a particular user account.
            //% "Allow apps to download and show images from your %1 storage."
            return qsTrId("components_accounts-la-service_description_images").arg(providerDisplayName)
        } else if (service.name == "nextcloud-posts") {
            //: Describes the effect of enabling the "Notifications" service for a particular user account.
            //% "Allow apps to show and delete your %1 notifications."
            return qsTrId("components_accounts-la-service_description_notifications").arg(providerDisplayName)
        }

        return ""
    }

    function joinServerPathInAddress(serverAddress, absolutePath) {
        return _accountUtil.joinServerPathInAddress(serverAddress, absolutePath)
    }

    property JollaAccountUtilities _accountUtil: JollaAccountUtilities {}

    function countCheckedSwitches(repeater) {
        var n = 0
        for (var i = 0; i < repeater.count; ++i) {
            if (repeater.itemAt(i).checked) {
                n++
            }
        }
        return n
    }
}
