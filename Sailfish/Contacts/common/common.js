.pragma library
.import org.nemomobile.contacts 1.0 as Contacts

var isInitialized = false

var labelNames = {}
var typeNames = {}
var subTypeNames = {}
var subTypeOrder = {}

var subTypeDisplayOrder = []
var subTypeDisplaySeparator

var labelDisplayOrder = []
var labelDisplaySeparator

var addressFields = []
var addressSummaryDisplayOrder = []
var addressSummaryDisplaySeparators = []

function _isArray(obj) {
    return (Object.prototype.toString.call(obj) === '[object Array]')
}

function _registerLabelName(label, name) {
    labelNames[label] = name
}
function _registerTypeName(type, name) {
    typeNames[type] = name
}
function _registerSubTypeName(type, subType, name) {
    var existing = 0
    if (!subTypeNames.hasOwnProperty(type)) {
        subTypeOrder[type] = {}
        subTypeNames[type] = {}
    } else {
        for (var value in subTypeOrder[type]) {
            ++existing
        }
    }
    subTypeOrder[type][subType] = existing
    subTypeNames[type][subType] = name
}

function init(person) {
    if (isInitialized) {
        return
    }
    isInitialized = true

    // Label types:
    //% "personal"
    _registerLabelName(person.HomeLabel, qsTrId("components_contacts-la-short_detail_label_personal"))
    //% "work"
    _registerLabelName(person.WorkLabel, qsTrId("components_contacts-la-short_detail_label_work"))
    //% "other"
    _registerLabelName(person.OtherLabel, qsTrId("components_contacts-la-short_detail_label_other"))

    // Name types:
    //% "first name"
    _registerTypeName(person.FirstNameType, qsTrId("components_contacts-la-detail_type_first_name"))
    //% "last name"
    _registerTypeName(person.LastNameType, qsTrId("components_contacts-la-detail_type_last_name"))
    //% "middle name"
    _registerTypeName(person.MiddleNameType, qsTrId("components_contacts-la-detail_type_middle_name"))
    // Not yet used:
    // person.PrefixType
    // person.SuffixType

    // Organization types:
    //% "company"
    _registerTypeName(person.CompanyType, qsTrId("components_contacts-la-detail_type-company"))
    //% "title"
    _registerTypeName(person.TitleType, qsTrId("components_contacts-la-detail_type_title"))
    //% "role"
    _registerTypeName(person.RoleType, qsTrId("components_contacts-la-detail_type_role"))
    //% "department"
    _registerTypeName(person.DepartmentType, qsTrId("components_contacts-la-detail_type_department"))

    //% "nickname"
    _registerTypeName(person.NicknameType, qsTrId("components_contacts-la-detail_type_nickname"))

    //% "phone"
    _registerTypeName(person.PhoneNumberType, qsTrId("components_contacts-la-detail_type_phone"))

    //% "email"
    _registerTypeName(person.EmailAddressType, qsTrId("components_contacts-la-detail_type_email"))

    //% "IM"
    _registerTypeName(person.OnlineAccountType, qsTrId("components_contacts-la-detail_type_im"))

    //% "address"
    _registerTypeName(person.AddressType, qsTrId("components_contacts-la-detail_type_address"))

    //% "website"
    _registerTypeName(person.WebsiteType, qsTrId("components_contacts-la-detail_type_website"))

    //% "birthday"
    _registerTypeName(person.BirthdayType, qsTrId("components_contacts-la-detail_type_birthday"))

    //% "anniversary"
    _registerTypeName(person.AnniversaryType, qsTrId("components_contacts-la-detail_type_anniversary"))

    // SubTypes - registered in order of descending primacy
    //% "assistant"
    _registerSubTypeName(person.PhoneNumberType, person.PhoneSubTypeAssistant, qsTrId("components_contacts-la-detail_type_phone_assistant"))
    //% "fax"
    _registerSubTypeName(person.PhoneNumberType, person.PhoneSubTypeFax, qsTrId("components_contacts-la-detail_type_phone_fax"))
    //% "pager"
    _registerSubTypeName(person.PhoneNumberType, person.PhoneSubTypePager, qsTrId("components_contacts-la-detail_type_phone_pager"))
    //% "modem"
    _registerSubTypeName(person.PhoneNumberType, person.PhoneSubTypeModem, qsTrId("components_contacts-la-detail_type_phone_modem"))
    //% "video"
    _registerSubTypeName(person.PhoneNumberType, person.PhoneSubTypeVideo, qsTrId("components_contacts-la-detail_type_phone_video"))
    //% "BBS"
    _registerSubTypeName(person.PhoneNumberType, person.PhoneSubTypeBulletinBoardSystem, qsTrId("components_contacts-la-detail_type_phone_bbs"))
    //% "car"
    _registerSubTypeName(person.PhoneNumberType, person.PhoneSubTypeCar, qsTrId("components_contacts-la-detail_type_phone_car"))
    //% "mobile"
    _registerSubTypeName(person.PhoneNumberType, person.PhoneSubTypeMobile, qsTrId("components_contacts-la-detail_type_phone_mobile"))
    //% "landline"
    _registerSubTypeName(person.PhoneNumberType, person.PhoneSubTypeLandline, qsTrId("components_contacts-la-detail_type_phone_landline"))
    //% "voice"
    _registerSubTypeName(person.PhoneNumberType, person.PhoneSubTypeVoice, qsTrId("components_contacts-la-detail_type_phone_voice"))
    //% "messaging"
    _registerSubTypeName(person.PhoneNumberType, person.PhoneSubTypeMessagingCapable, qsTrId("components_contacts-la-detail_type_phone_messaging"))
    //% "DTMF"
    _registerSubTypeName(person.PhoneNumberType, person.PhoneSubTypeDtmfMenu, qsTrId("components_contacts-la-detail_type_phone_dtmf"))
    //% "international"
    _registerSubTypeName(person.AddressType, person.AddressSubTypeInternational, qsTrId("components_contacts-la-detail_type_address_international"))
    //% "parcel"
    _registerSubTypeName(person.AddressType, person.AddressSubTypeParcel, qsTrId("components_contacts-la-detail_type_address_parcel"))
    //% "postal"
    _registerSubTypeName(person.AddressType, person.AddressSubTypePostal, qsTrId("components_contacts-la-detail_type_address_postal"))
    //% "domestic"
    _registerSubTypeName(person.AddressType, person.AddressSubTypeDomestic, qsTrId("components_contacts-la-detail_type_address_domestic"))
    //% "video"
    _registerSubTypeName(person.OnlineAccountType, person.OnlineAccountSubTypeVideoShare, qsTrId("components_contacts-la-detail_type_im_video"))
    //% "VOIP"
    _registerSubTypeName(person.OnlineAccountType, person.OnlineAccountSubTypeSipVoip, qsTrId("components_contacts-la-detail_type_im_sipvoip"))
    //% "SIP"
    _registerSubTypeName(person.OnlineAccountType, person.OnlineAccountSubTypeSip, qsTrId("components_contacts-la-detail_type_im_sip"))
    //% "IMPP"
    _registerSubTypeName(person.OnlineAccountType, person.OnlineAccountSubTypeImpp, qsTrId("components_contacts-la-detail_type_im_impp"))

    // The remaining sub-types are exclusive rather than cumulative - order is irrelevant
    //% "home page"
    _registerSubTypeName(person.WebsiteType, person.WebsiteSubTypeHomePage, qsTrId("components_contacts-la-detail_type_website_homepage"))
    //% "blog"
    _registerSubTypeName(person.WebsiteType, person.WebsiteSubTypeBlog, qsTrId("components_contacts-la-detail_type_website_blog"))
    //% "favorite"
    _registerSubTypeName(person.WebsiteType, person.WebsiteSubTypeFavorite, qsTrId("components_contacts-la-detail_type_website_favorite"))
    //% "wedding"
    _registerSubTypeName(person.AnniversaryType, person.AnniversarySubTypeWedding, qsTrId("components_contacts-la-detail_type_anniversary_wedding"))
    //% "engagement"
    _registerSubTypeName(person.AnniversaryType, person.AnniversarySubTypeEngagement, qsTrId("components_contacts-la-detail_type_anniversary_engagement"))
    //% "house"
    _registerSubTypeName(person.AnniversaryType, person.AnniversarySubTypeHouse, qsTrId("components_contacts-la-detail_type_anniversary_house"))
    //% "employment"
    _registerSubTypeName(person.AnniversaryType, person.AnniversarySubTypeEmployment, qsTrId("components_contacts-la-detail_type_anniversary_employment"))
    //% "memorial"
    _registerSubTypeName(person.AnniversaryType, person.AnniversarySubTypeMemorial, qsTrId("components_contacts-la-detail_type_anniversary_memorial"))

    var tokenizer = /[^<]*(<[^>]+>)?/g
    var parser = /([^>]*)<([^>]+)>?/

    subTypeDisplayOrder = ['S', 'T']
    subTypeDisplaySeparator = ' ' + String.fromCharCode(0x2022) + ' ' // bullet

    //: Define the order and separator of type/subtype, such as 'Mobile'/'phone' - do not translate the <...> tokens [Only required to change default]
    //: Example: "<subtype> <type>"
    var displayFormat = qsTrId("components_contacts-la-subtype_display_format")
    if (displayFormat && displayFormat != 'components_contacts-la-subtype_display_format') {
        // If this is a valid format, override the predefined display order
        var matches = displayFormat.match(tokenizer)
        if (matches.length == 3) {
            var first = matches[0].match(parser)
            var second = matches[1].match(parser)
            if (first[2] == 'type' && second[2] == 'subtype') {
                subTypeDisplayOrder = ['T', 'S']
                subTypeDisplaySeparator = second[1]
                displayFormat = ''
            } else if (first[2] == 'subtype' && second[2] == 'type') {
                subTypeDisplaySeparator = second[1]
                displayFormat = ''
            }
        }
        if (displayFormat) {
            console.log("Unable to parse subtype display format:", displayFormat)
        }
    }

    labelDisplayOrder = ['L', 'D']
    labelDisplaySeparator = ' ' + String.fromCharCode(0x2022) + ' ' // bullet

    //: Define the order and separator of label/detail, such as 'Work'/'address' - do not translate the <...> tokens [Only required to change default]
    //: Example: "<label> <detail>"
    displayFormat = qsTrId("components_contacts-la-label_display_format")
    if (displayFormat && displayFormat != 'components_contacts-la-label_display_format') {
        // If this is a valid format, override the predefined display order
        var matches = displayFormat.match(tokenizer)
        if (matches.length == 3) {
            var first = matches[0].match(parser)
            var second = matches[1].match(parser)
            if (first[2] == 'detail' && second[2] == 'label') {
                labelDisplayOrder = ['D', 'L']
                labelDisplaySeparator = second[1]
                displayFormat = ''
            } else if (first[2] == 'label' && second[2] == 'detail') {
                labelDisplaySeparator = second[1]
                displayFormat = ''
            }
        }
        if (displayFormat) {
            console.log("Unable to parse label display format:", displayFormat)
        }
    }

    // note this is also the ordering for address strings in Person::addresses
    addressFields = [
        person.AddressStreetField,
        person.AddressLocalityField,
        person.AddressRegionField,
        person.AddressPostcodeField,
        person.AddressCountryField,
        person.AddressPOBoxField
    ]
    addressSummaryDisplayOrder = [
        person.AddressPOBoxField,
        person.AddressStreetField,
        person.AddressLocalityField,
        person.AddressPostcodeField,
        person.AddressRegionField,
        person.AddressCountryField
    ]
    addressSummaryDisplaySeparators = [
        '',
        ', ',
        ', ',
        ', ',
        ', ',
        ', ',
        ''
    ]

    //: Define the order and formatting of address elements - do not translate the <...> tokens [Only required to change default]
    //: Example: "<pobox>, <street>, <city>, <zipcode>, <region>, <country>"
    displayFormat = qsTrId("components_contacts-la-address_display_format")
    if (displayFormat && displayFormat != 'components_contacts-la-address_display_format') {
        // If this is a valid format, override the predefined display order
        var matches = displayFormat.match(tokenizer)
        if (matches.length == 7) {
            var tokens = []
            var separators = []
            var mapping = {
                'pobox': person.AddressPOBoxField,
                'street': person.AddressStreetField,
                'city': person.AddressLocalityField,
                'zipcode': person.AddressPostcodeField,
                'region': person.AddressRegionField,
                'country': person.AddressCountryField
            }
            for (var i = 0; i < 7; ++i) {
                var separator = ''
                var token = ''
                var parts = matches[i].match(parser)
                if (parts && parts.length == 3) {
                    separator = parts[1]
                    token = parts[2]
                }
                separators.push(separator)
                if (mapping[token] != undefined) {
                    tokens.push(mapping[token])
                    delete mapping[token]
                }
            }
            // If we allocated all tokens, the mapping will be empty
            if (JSON.stringify(mapping) == '{}') {
                addressSummaryDisplayOrder = tokens
                addressSummaryDisplaySeparators = separators
                displayFormat = ''
            }
        }
        if (displayFormat) {
            console.log("Unable to parse address display format:", displayFormat)
        }
    }
}

function _capitalize(text) {
    if (text != '') {
        var firstChar = text.charAt(0)
        if (firstChar.toUpperCase() == firstChar) {
            return text
        }
        return text.charAt(0).toUpperCase() + text.slice(1)
    }
    return ''
}

function getNameForLabelledDetail(detail, label) {
    if (labelNames[label] != undefined) {
        var labelText = labelNames[label]
        if (detail && detail != '') {
            var first = (labelDisplayOrder[0] == 'L' ? labelText : detail)
            var second = (labelDisplayOrder[0] == 'L' ? detail : labelText)
            return _capitalize(first) + labelDisplaySeparator + _capitalize(second)
        }
        return _capitalize(labelText)
    }
    return _capitalize(detail)
}

function getNameForDetailType(detailType, label, omitType) {
    var typeName = ''
    if (omitType != true && typeNames[detailType] !== undefined) {
        typeName = typeNames[detailType]
    }
    return getNameForLabelledDetail(typeName, label)
}

function _subTypePresent(subType, subTypes) {
    for (var i = 0; i < subTypes.length; ++i) {
        if (subTypes[i] == subType) {
            return true
        }
    }
    return false;
}

function _getPrimarySubType(type, subTypes) {
    var lowestType

    if (_isArray(subTypes) && subTypes != []) {
        // Select the lowest ordered subType for this set of sub-types
        var lowestOrder = Number.MAX_VALUE
        for (var i = 0; i < subTypes.length; ++i) {
            var sub = subTypes[i]
            var order = subTypeOrder[type][subTypes[i]]
            if (order < lowestOrder) {
                lowestOrder = order
                lowestType = sub
            }
        }
    }

    return lowestType
}

function getNameForDetailSubType(detailType, subType, label, omitType) {
    var typeName = ''
    var subTypeName = ''

    if (typeNames[detailType] !== undefined) {
        typeName = typeNames[detailType]
    }
    if (subTypeNames[detailType] !== undefined) {
        var sub
        if (_isArray(subType)) {
            sub = _getPrimarySubType(detailType, subType)
        } else {
            sub = subType
        }
        if (subTypeNames[detailType][sub] !== undefined) {
            subTypeName = subTypeNames[detailType][sub]
        }
    }

    if (subTypeName == '') {
        return getNameForLabelledDetail(typeName, label)
    } else if (typeName == '' || omitType) {
        return getNameForLabelledDetail(subTypeName, label)
    }

    var first = (subTypeDisplayOrder[0] == 'S' ? subTypeName : typeName)
    var second = (subTypeDisplayOrder[0] == 'S' ? typeName : subTypeName)
    return getNameForLabelledDetail(first + subTypeDisplaySeparator + _capitalize(second), label)
}

function getNameForImProvider(displayName, providerName, label) {
    var name = displayName || providerName
    if (!name) {
        //% "Instant messaging"
        name = qsTrId("components_contacts-la-detail_type-im")
    }

    return getNameForLabelledDetail(name, label)
}

function addressStringToMap(addressString) {
    var map = {}
    if (addressString.trim() === "") {
        for (var i=0; i<addressFields.length; i++) {
            map[addressFields[i]] = ""
        }
    } else {
        var values = addressString.split('\n')
        for (var i=0; i<values.length; i++) {
            map[addressFields[i]] = values[i]
        }
    }
    return map
}

function getAddressSummary(addressString) {
    var details = addressStringToMap(addressString)
    var ret = addressSummaryDisplaySeparators[0]
    var sep = ""
    for (var i=0; i<addressSummaryDisplayOrder.length; i++) {
        var value = details[addressSummaryDisplayOrder[i]]
        if (value !== "") {
            ret += sep
            ret += value

            // Record the separator for this field, but only use it if there is more to follow
            sep = addressSummaryDisplaySeparators[i+1]
        }
    }
    return ret
}

function syncTargetDisplayName(person)
{
    if (!person) {
        console.log("syncTargetName(): invalid person specified")
        return ""
    }
    // user doesn't need to see these target types
    if (person.syncTarget === "aggregate"
            || person.syncTarget === "local"
            || person.syncTarget === "was_local") {
        return ""
    }
    return person.syncTarget
}

function syncTargetStringIcon(syncTarget)
{
    if (syncTarget === "aggregate"
            || syncTarget === "local"
            || syncTarget === "was_local") {
        return "image://theme/icon-m-phone"
    }
    return "image://theme/icon-m-region"
}

function syncTargetIcon(person)
{
    if (!person) {
        console.log("syncTargetIcon(): invalid person specified")
        return ""
    }
    return syncTargetStringIcon(person.syncTarget)
}

function isWritableContact(person) {
    if (!person) {
        console.log("isWritableContact(): invalid person specified")
        return false
    }
    // empty contacts, aggregates and local constituents are editable
    return (!person.syncTarget || person.syncTarget === "aggregate" || person.syncTarget === "local")
}

function pairString(description, value) {
    if (description && description.length > 0) {
        return description + " | " + value
    }
    return value
}

function selectableProperties(source, requiredProperty, deduplicator) {
    if (!source || requiredProperty === 0) {
        return undefined
    }

    var i
    var detail
    var properties = []
    if (requiredProperty & Contacts.PeopleModel.EmailAddressRequired) {
        var emailDetails = source.emailDetails
        if (deduplicator && deduplicator.removeDuplicateEmailAddresses) {
            emailDetails = deduplicator.removeDuplicateEmailAddresses(emailDetails)
        }
        for (i = 0; i < emailDetails.length; ++i) {
            detail = emailDetails[i]
            var name = getNameForDetailType(detail.type, detail.label, true)
            properties.push({
                "property": { "address": detail.address },
                "displayLabel": pairString(name, detail.address),
                "propertyType": "emailAddress"
            })
        }
    }
    if (requiredProperty & Contacts.PeopleModel.PhoneNumberRequired) {
        var phoneDetails = source.phoneDetails
        if (deduplicator && deduplicator.removeDuplicatePhoneNumbers) {
            phoneDetails = deduplicator.removeDuplicatePhoneNumbers(phoneDetails)
        }
        for (i = 0; i < phoneDetails.length; ++i) {
            detail = phoneDetails[i]
            var sub = _getPrimarySubType(detail.type, detail.subTypes)
            var name = getNameForDetailSubType(detail.type, sub, detail.label, true)
            properties.push({
                // TODO: We should switch 'property' to normalizedNumber at this point, in the future
                "property": { "number": detail.number },
                "displayLabel": pairString(name, detail.number),
                "propertyType": "phoneNumber"
            })
        }
    }
    if (requiredProperty & Contacts.PeopleModel.AccountUriRequired) {
        var accountDetails = source.accountDetails
        if (deduplicator && deduplicator.removeDuplicateOnlineAccounts) {
            accountDetails = deduplicator.removeDuplicateOnlineAccounts(accountDetails)
        }
        for (i = 0; i < accountDetails.length; ++i) {
            detail = accountDetails[i]
            if (detail.accountPath.length > 0) {
                properties.push({
                    "property": { "uri": detail.accountUri, "path": detail.accountPath },
                    "displayLabel": detail.accountUri,
                    "propertyType": "accountUri"
                })
            }
        }
    }

    return properties.length > 0 ? properties : undefined
}

function propertyAddressValue(propertyType, property)
{
    if (property != undefined) {
        if (propertyType == "accountUri") {
            return property.uri
        } else if (propertyType == "emailAddress") {
            return property.address
        } else if (propertyType == "phoneNumber") {
            return property.number
        }
    }

    return ""
}

function presenceDescription(presenceState) {
    switch (presenceState) {
        //: Presence state: available
        //% "Available"
        case Contacts.Person.PresenceAvailable: return qsTrId("components_contacts-la-presence_available")
        //: Presence state: away
        //% "Away"
        case Contacts.Person.PresenceAway: return qsTrId("components_contacts-la-presence_away")
        //: Presence state: extended away
        //% "Extended away"
        case Contacts.Person.PresenceExtendedAway: return qsTrId("components_contacts-la-presence_extended_away")
        //: Presence state: busy
        //% "Busy"
        case Contacts.Person.PresenceBusy: return qsTrId("components_contacts-la-presence_busy")
        //: Presence state: hidden
        //% "Hidden"
        case Contacts.Person.PresenceHidden: return qsTrId("components_contacts-la-presence_hidden")
        //: Presence state: offline
        //% "Offline"
        case Contacts.Person.PresenceOffline: return qsTrId("components_contacts-la-presence_offline")
        //: Presence state: unknown
        //% "Unknown"
        case Contacts.Person.PresenceUnknown: return qsTrId("components_contacts-la-presence_unknown")
    }
    return '<Unknown:' + presenceState + '>'
}

function descriptionForPhoneNumber(source, normalized, minimized, deduplicator) {
    var i
    var detail

    // Find a matching phone number
    var phoneDetails = source.phoneDetails
    if (deduplicator && deduplicator.removeDuplicatePhoneNumbers) {
        phoneDetails = deduplicator.removeDuplicatePhoneNumbers(phoneDetails)
    }
    for (i = 0; i < phoneDetails.length; ++i) {
        if (phoneDetails[i].normalizedNumber == normalized) {
            detail = phoneDetails[i]
            break;
        }
    }
    if (!detail) {
        for (i = 0; i < phoneDetails.length; ++i) {
            if (phoneDetails[i].minimizedNumber == minimized) {
                detail = phoneDetails[i]
                break;
            }
        }
    }
    if (detail) {
        return getNameForDetailSubType(detail.type, detail.subTypes, detail.label, true)
    }

    return ""
}

function descriptionForAccountUri(source, localUid, remoteUid, deduplicator) {
    var accountDetails = source.accountDetails
    if (deduplicator && deduplicator.removeDuplicateOnlineAccounts) {
        accountDetails = deduplicator.removeDuplicateOnlineAccounts(accountDetails)
    }
    for (var i = 0; i < accountDetails.length; ++i) {
        var detail = accountDetails[i]
        if (detail.accountPath == localUid && detail.accountUri == remoteUid)
            return getNameForImProvider(detail.serviceProviderName, detail.serviceProvider, detail.label)
    }

    return ""
}

