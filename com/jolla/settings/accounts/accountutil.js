.pragma library


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
    }
    return ""
}

function serviceDisplayNameFromType(serviceType, serviceDisplayName) {
    switch (serviceType) {
    case "e-mail":
        return qsTrId("components_accounts-la-service_name_email")
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
