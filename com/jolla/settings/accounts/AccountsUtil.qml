pragma Singleton
import QtQml 2.2

QtObject {
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

        //% "Backup"
        QT_TRID_NOOP("components_accounts-la-sync_service_backup")

        //: Notifications
        //% "Notifications"
        QT_TRID_NOOP("components_accounts-la-sync_service_name_notifications")

        //% "Images and Photos"
        QT_TRID_NOOP("components_accounts-la-sync_service_images_and_photos")

        //: More precise name for cloud storage services
        //% "Cloud storage"
        QT_TRID_NOOP("components_accounts-la-service_name_cloud_storage")
    }

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
            return qsTrId("components_accounts-la-sync_service_name_calendar")
        case "google-contacts":
        case "facebook-contacts":
        case "vk-contacts":
            return qsTrId("components_accounts-la-sync_service_name_contacts")
        case "facebook-images":
        case "onedrive-images":
        case "dropbox-images":
        case "vk-images":
            return qsTrId("components_accounts-la-sync_service_name_images")
        case "onedrive-backup":
        case "dropbox-backup":
            return qsTrId("components_accounts-la-service_name_storage")
        case "facebook-microblog":
            return qsTrId("components_accounts-la-sync_service_name_notifications")
        case "twitter-microblog":
            return qsTrId("components_accounts-la-sync_service_name_tweets_and_notifications")
        case "google-gmail":
        case "email":
            return qsTrId("components_accounts-la-service_name_email")
        case "vk-microblog":
            return qsTrId("components_accounts-la-sync_service_name_feeds_and_notifications")
        case "vk-microblog":
            return qsTrId("components_accounts-la-sync_service_name_feeds_and_notifications")

        case "nextcloud-backup":
            return qsTrId("components_accounts-la-sync_service_backup")
        case "nextcloud-images":
            return qsTrId("components_accounts-la-sync_service_images_and_photos")
        case "nextcloud-posts":
            return qsTrId("components_accounts-la-sync_service_name_notifications")
        }
        return ""
    }

    function serviceDisplayNameFromType(serviceType, serviceDisplayName) {
        switch (serviceType) {
        case "caldav":
            return qsTrId("components_accounts-la-sync_service_name_calendar")
        case "carddav":
            return qsTrId("components_accounts-la-sync_service_name_contacts")
        case "e-mail":
            return qsTrId("components_accounts-la-service_name_email")
        case "images":
            return qsTrId("components_accounts-la-sync_service_name_images")
        case "IM":
            return qsTrId("components_accounts-la-service_name_im")
        case "microblogging":
            return qsTrId("components_accounts-la-service_name_microblogging")
        case "sharing":
            return qsTrId("components_accounts-la-service_name_sharing")
        case "storage":
            return qsTrId("components_accounts-la-service_name_storage")
        default:
            return serviceDisplayName
        }
    }

    function serviceDescription(serviceType, providerDisplayName, providerName) {
        switch (serviceType) {
        case "e-mail":
            return qsTrId("components_accounts-la-service_description_email").arg(providerDisplayName)
        case "IM":
            return qsTrId("components_accounts-la-service_description_im").arg(providerDisplayName)
        case "microblogging":
            return qsTrId("components_accounts-la-service_description_microblogging").arg(providerDisplayName)
        case "sharing":
            return qsTrId("components_accounts-la-service_description_sharing").arg(providerDisplayName)
        case "storage":
            return qsTrId("components_accounts-la-service_description_storage").arg(providerDisplayName)
        default:
            return ""
        }
    }
}
