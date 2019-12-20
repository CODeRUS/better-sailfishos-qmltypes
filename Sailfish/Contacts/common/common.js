.pragma library
.import Sailfish.Silica 1.0 as Silica
.import org.nemomobile.contacts 1.0 as Contacts

var isInitialized = false

var labels = []
var labelNames = {}
var typeNames = {}
var subTypeNames = {}
var subTypeOrder = {}
var detailShortNames = {}

var descriptions = {}
var inputHints = {}

var subTypeDisplayOrder = []
var subTypeDisplaySeparator

var labelDisplayOrder = []
var labelDisplaySeparator

var addressFields = []
var addressSummaryDisplayOrder = []
var addressSummaryDisplaySeparators = []

var inputMethodHints = {}

function isArray(obj) {
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

function _registerField(type, field, description, inputHint) {
    if (description !== undefined) {
        if (field !== undefined) {
            if (!descriptions.hasOwnProperty(type)) {
                descriptions[type] = {}
            }
            descriptions[type][field] = description
        } else {
            descriptions[type] = description
        }
    }
    if (inputHint !== undefined) {
        if (field !== undefined) {
            if (!inputHints.hasOwnProperty(type)) {
                inputHints[type] = {}
            }
            inputHints[type][field] = inputHint
        } else {
            inputHints[type] = inputHint
        }
    }
}

function init() {
    if (isInitialized) {
        return
    }
    isInitialized = true

    labels = [ Contacts.Person.NoLabel, Contacts.Person.HomeLabel, Contacts.Person.WorkLabel, Contacts.Person.OtherLabel ]

    // Label types:
    //% "personal"
    _registerLabelName(Contacts.Person.HomeLabel, qsTrId("components_contacts-la-short_detail_label_personal"))
    //% "work"
    _registerLabelName(Contacts.Person.WorkLabel, qsTrId("components_contacts-la-short_detail_label_work"))
    //% "other"
    _registerLabelName(Contacts.Person.OtherLabel, qsTrId("components_contacts-la-short_detail_label_other"))

    // Name types:
    //% "first name"
    _registerTypeName(Contacts.Person.FirstNameType, qsTrId("components_contacts-la-detail_type_first_name"))
    //% "last name"
    _registerTypeName(Contacts.Person.LastNameType, qsTrId("components_contacts-la-detail_type_last_name"))
    //% "middle name"
    _registerTypeName(Contacts.Person.MiddleNameType, qsTrId("components_contacts-la-detail_type_middle_name"))
    // Not yet used:
    // Contacts.Person.PrefixType
    // Contacts.Person.SuffixType

    // Organization types:
    //% "company"
    _registerTypeName(Contacts.Person.CompanyType, qsTrId("components_contacts-la-detail_type-company"))
    //% "job title"
    _registerTypeName(Contacts.Person.TitleType, qsTrId("components_contacts-la-detail_type_job_title"))
    //% "role"
    _registerTypeName(Contacts.Person.RoleType, qsTrId("components_contacts-la-detail_type_role"))
    //% "department"
    _registerTypeName(Contacts.Person.DepartmentType, qsTrId("components_contacts-la-detail_type_department"))

    //% "nickname"
    _registerTypeName(Contacts.Person.NicknameType, qsTrId("components_contacts-la-detail_type_nickname"))

    //% "phone"
    _registerTypeName(Contacts.Person.PhoneNumberType, qsTrId("components_contacts-la-detail_type_phone"))

    //% "email"
    _registerTypeName(Contacts.Person.EmailAddressType, qsTrId("components_contacts-la-detail_type_email"))

    //% "IM"
    _registerTypeName(Contacts.Person.OnlineAccountType, qsTrId("components_contacts-la-detail_type_im"))

    //% "address"
    _registerTypeName(Contacts.Person.AddressType, qsTrId("components_contacts-la-detail_type_address"))

    //% "website"
    _registerTypeName(Contacts.Person.WebsiteType, qsTrId("components_contacts-la-detail_type_website"))

    //% "birthday"
    _registerTypeName(Contacts.Person.BirthdayType, qsTrId("components_contacts-la-detail_type_birthday"))

    //% "date"
    _registerTypeName(Contacts.Person.AnniversaryType, qsTrId("components_contacts-la-detail_type_date"))

    //% "note"
    _registerTypeName(Contacts.Person.NoteType, qsTrId("components_contacts-la-detail_type_note"))

    // SubTypes - registered in order of descending primacy
    //% "assistant"
    _registerSubTypeName(Contacts.Person.PhoneNumberType, Contacts.Person.PhoneSubTypeAssistant, qsTrId("components_contacts-la-detail_type_phone_assistant"))
    //% "fax"
    _registerSubTypeName(Contacts.Person.PhoneNumberType, Contacts.Person.PhoneSubTypeFax, qsTrId("components_contacts-la-detail_type_phone_fax"))
    //% "pager"
    _registerSubTypeName(Contacts.Person.PhoneNumberType, Contacts.Person.PhoneSubTypePager, qsTrId("components_contacts-la-detail_type_phone_pager"))
    //% "modem"
    _registerSubTypeName(Contacts.Person.PhoneNumberType, Contacts.Person.PhoneSubTypeModem, qsTrId("components_contacts-la-detail_type_phone_modem"))
    //% "video"
    _registerSubTypeName(Contacts.Person.PhoneNumberType, Contacts.Person.PhoneSubTypeVideo, qsTrId("components_contacts-la-detail_type_phone_video"))
    //% "BBS"
    _registerSubTypeName(Contacts.Person.PhoneNumberType, Contacts.Person.PhoneSubTypeBulletinBoardSystem, qsTrId("components_contacts-la-detail_type_phone_bbs"))
    //% "car"
    _registerSubTypeName(Contacts.Person.PhoneNumberType, Contacts.Person.PhoneSubTypeCar, qsTrId("components_contacts-la-detail_type_phone_car"))
    //% "mobile"
    _registerSubTypeName(Contacts.Person.PhoneNumberType, Contacts.Person.PhoneSubTypeMobile, qsTrId("components_contacts-la-detail_type_phone_mobile"))
    //% "landline"
    _registerSubTypeName(Contacts.Person.PhoneNumberType, Contacts.Person.PhoneSubTypeLandline, qsTrId("components_contacts-la-detail_type_phone_landline"))
    //% "voice"
    _registerSubTypeName(Contacts.Person.PhoneNumberType, Contacts.Person.PhoneSubTypeVoice, qsTrId("components_contacts-la-detail_type_phone_voice"))
    //% "messaging"
    _registerSubTypeName(Contacts.Person.PhoneNumberType, Contacts.Person.PhoneSubTypeMessagingCapable, qsTrId("components_contacts-la-detail_type_phone_messaging"))
    //% "DTMF"
    _registerSubTypeName(Contacts.Person.PhoneNumberType, Contacts.Person.PhoneSubTypeDtmfMenu, qsTrId("components_contacts-la-detail_type_phone_dtmf"))
    //% "international"
    _registerSubTypeName(Contacts.Person.AddressType, Contacts.Person.AddressSubTypeInternational, qsTrId("components_contacts-la-detail_type_address_international"))
    //% "parcel"
    _registerSubTypeName(Contacts.Person.AddressType, Contacts.Person.AddressSubTypeParcel, qsTrId("components_contacts-la-detail_type_address_parcel"))
    //% "postal"
    _registerSubTypeName(Contacts.Person.AddressType, Contacts.Person.AddressSubTypePostal, qsTrId("components_contacts-la-detail_type_address_postal"))
    //% "domestic"
    _registerSubTypeName(Contacts.Person.AddressType, Contacts.Person.AddressSubTypeDomestic, qsTrId("components_contacts-la-detail_type_address_domestic"))
    //% "video"
    _registerSubTypeName(Contacts.Person.OnlineAccountType, Contacts.Person.OnlineAccountSubTypeVideoShare, qsTrId("components_contacts-la-detail_type_im_video"))
    //% "VOIP"
    _registerSubTypeName(Contacts.Person.OnlineAccountType, Contacts.Person.OnlineAccountSubTypeSipVoip, qsTrId("components_contacts-la-detail_type_im_sipvoip"))
    //% "SIP"
    _registerSubTypeName(Contacts.Person.OnlineAccountType, Contacts.Person.OnlineAccountSubTypeSip, qsTrId("components_contacts-la-detail_type_im_sip"))
    //% "IMPP"
    _registerSubTypeName(Contacts.Person.OnlineAccountType, Contacts.Person.OnlineAccountSubTypeImpp, qsTrId("components_contacts-la-detail_type_im_impp"))

    // The remaining sub-types are exclusive rather than cumulative - order is irrelevant
    //% "home page"
    _registerSubTypeName(Contacts.Person.WebsiteType, Contacts.Person.WebsiteSubTypeHomePage, qsTrId("components_contacts-la-detail_type_website_homepage"))
    //% "blog"
    _registerSubTypeName(Contacts.Person.WebsiteType, Contacts.Person.WebsiteSubTypeBlog, qsTrId("components_contacts-la-detail_type_website_blog"))
    //% "favorite"
    _registerSubTypeName(Contacts.Person.WebsiteType, Contacts.Person.WebsiteSubTypeFavorite, qsTrId("components_contacts-la-detail_type_website_favorite"))
    //% "wedding"
    _registerSubTypeName(Contacts.Person.AnniversaryType, Contacts.Person.AnniversarySubTypeWedding, qsTrId("components_contacts-la-detail_type_anniversary_wedding"))
    //% "engagement"
    _registerSubTypeName(Contacts.Person.AnniversaryType, Contacts.Person.AnniversarySubTypeEngagement, qsTrId("components_contacts-la-detail_type_anniversary_engagement"))
    //% "house"
    _registerSubTypeName(Contacts.Person.AnniversaryType, Contacts.Person.AnniversarySubTypeHouse, qsTrId("components_contacts-la-detail_type_anniversary_house"))
    //% "employment"
    _registerSubTypeName(Contacts.Person.AnniversaryType, Contacts.Person.AnniversarySubTypeEmployment, qsTrId("components_contacts-la-detail_type_anniversary_employment"))
    //% "memorial"
    _registerSubTypeName(Contacts.Person.AnniversaryType, Contacts.Person.AnniversarySubTypeMemorial, qsTrId("components_contacts-la-detail_type_anniversary_memorial"))

    _registerField(Contacts.Person.AddressType, Contacts.Person.AddressStreetField,
        //% "Street"
        qsTrId("components_contacts-la-detail_field_address_street"))
    _registerField(Contacts.Person.AddressType, Contacts.Person.AddressLocalityField,
        //% "City"
        qsTrId("components_contacts-la-detail_field_address_locality"))
    _registerField(Contacts.Person.AddressType, Contacts.Person.AddressRegionField,
        //% "Region"
        qsTrId("components_contacts-la-detail_field_address_region"))
    _registerField(Contacts.Person.AddressType, Contacts.Person.AddressPostcodeField,
        //% "Postal code"
        qsTrId("components_contacts-la-detail_field_address_postcode"),
        Qt.ImhPreferNumbers)
    _registerField(Contacts.Person.AddressType, Contacts.Person.AddressCountryField,
        //% "Country"
        qsTrId("components_contacts-la-detail_field_address_country"))
    _registerField(Contacts.Person.AddressType, Contacts.Person.AddressPOBoxField,
        //% "P.O. box"
        qsTrId("components_contacts-la-detail_field_address_pobox"),
        Qt.ImhPreferNumbers)

    var tokenizer = /[^<]*(<[^>]+>)?/g
    var parser = /([^>]*)<([^>]+)>?/

    subTypeDisplayOrder = ['S']
    subTypeDisplaySeparator = ' ' + String.fromCharCode(0x2022) + ' ' // bullet
    var matches
    var first
    var second

    //: Define the order and separator of type/subtype, such as 'Mobile'/'phone' - do not translate the <...> tokens [Only required to change default]
    //: Example: "<subtype> <type>"
    var displayFormat = qsTrId("components_contacts-la-subtype_display_format")
    if (displayFormat && displayFormat != 'components_contacts-la-subtype_display_format') {
        // If this is a valid format, override the predefined display order
        matches = displayFormat.match(tokenizer)
        if (matches.length == 3) {
            first = matches[0].match(parser)
            second = matches[1].match(parser)
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
        matches = displayFormat.match(tokenizer)
        if (matches.length == 3) {
            first = matches[0].match(parser)
            second = matches[1].match(parser)
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
        Contacts.Person.AddressStreetField,
        Contacts.Person.AddressLocalityField,
        Contacts.Person.AddressRegionField,
        Contacts.Person.AddressPostcodeField,
        Contacts.Person.AddressCountryField,
        Contacts.Person.AddressPOBoxField
    ]
    addressSummaryDisplayOrder = [
        Contacts.Person.AddressPOBoxField,
        Contacts.Person.AddressStreetField,
        Contacts.Person.AddressLocalityField,
        Contacts.Person.AddressPostcodeField,
        Contacts.Person.AddressRegionField,
        Contacts.Person.AddressCountryField
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
        matches = displayFormat.match(tokenizer)
        if (matches.length == 7) {
            var tokens = []
            var separators = []
            var mapping = {
                'pobox': Contacts.Person.AddressPOBoxField,
                'street': Contacts.Person.AddressStreetField,
                'city': Contacts.Person.AddressLocalityField,
                'zipcode': Contacts.Person.AddressPostcodeField,
                'region': Contacts.Person.AddressRegionField,
                'country': Contacts.Person.AddressCountryField
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

function getPrimarySubType(type, subTypes) {
    var lowestType

    if (isArray(subTypes) && subTypes != []) {
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
        if (isArray(subType)) {
            sub = getPrimarySubType(detailType, subType)
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
    if (subTypeDisplayOrder.length > 1) {
        var second = (subTypeDisplayOrder[0] == 'S' ? typeName : subTypeName)
        return getNameForLabelledDetail(first + subTypeDisplaySeparator + _capitalize(second), label)
    } else {
        return getNameForLabelledDetail(first, label)
    }
}

function getDescriptionForDetail(detailType, field)
{
    if (descriptions[detailType] !== undefined) {
        if (field !== undefined) {
            return descriptions[detailType][field]
        }
        return descriptions[detailType]
    }
    return ""
}

function getInputMethodHintsForDetail(detailType, field)
{
    if (inputHints[detailType] !== undefined) {
        if (field != undefined) {
            return inputHints[detailType][field]
        }
        return inputHints[detailType]
    }
    return undefined
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

function getDateButtonText(formatObject, dateValue) {
    return (isNaN(dateValue) ? getSetDateText() : formatObject.formatDate(dateValue, formatObject.DateLong))
}

function getNoLabelText() {
    //: When selecting a detail label, to select none of the options
    //% "None"
    return qsTrId("components_contacts-la-detail_no_label")
}

function getSelectLabelText() {
    //: Select "personal", "work" or "other" to label this contact detail (phone, email, address etc.) appropriately
    //% "Select label"
    return qsTrId("components_contacts-bt-detail_select_label")
}

function getNoTypeText() {
    //: When selecting a detail type, to select none of the options
    //% "None"
    return qsTrId("components_contacts-la-detail_no_type")
}

function getSetDateText() {
    //: Set date value
    //% "Set date"
    return qsTrId("components_contacts-ph-contact_date")
}

function getDetailDeletionText() {
    //: Delete contact detail
    //% "Remove"
    return qsTrId("components_contacts-bt-contact_field_delete")
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
    init()

    var i
    var detail
    var properties = []
    var name
    if (requiredProperty & Contacts.PeopleModel.EmailAddressRequired) {
        var emailDetails = source.emailDetails
        if (deduplicator && deduplicator.removeDuplicateEmailAddresses) {
            emailDetails = deduplicator.removeDuplicateEmailAddresses(emailDetails)
        }
        for (i = 0; i < emailDetails.length; ++i) {
            detail = emailDetails[i]
            name = getNameForDetailType(detail.type, detail.label, true)
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
            var sub = getPrimarySubType(detail.type, detail.subTypes)
            name = getNameForDetailSubType(detail.type, sub, detail.label, true)
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

function ensureContactComplete(contact, seasideFilteredModel) {
    if (contact.id) {
        // Ensure that we use the cache's canonical version of this contact
        contact = seasideFilteredModel.personById(contact.id)
    }
    if (!contact.complete) {
        contact.ensureComplete()
    }
    return contact
}

function editContact(contact, peopleModel, pageStack, pageStackOperationType) {
    if (pageStack.currentPage.status !== Silica.PageStatus.Active) {
        console.log("Cannot push contact editor onto pagestack, status != PageStatus.Active for current page:",
                    pageStack.currentPage)
        return
    }
    if (!contact || !peopleModel || !pageStack) {
        console.log("editContact() failed, invalid arguments!", contact, peopleModel, pageStack)
        return
    }

    var savePageProperties = {
        "peopleModel": peopleModel,
        "contactId": contact.id
    }

    var editorProperties = {
        "peopleModel": peopleModel,
        "subject": contact.id === 0
                   ? contact
                   : peopleModel.personById(contact.id),  // Ensure we're modifying the canonical instance of this contact
        "acceptDestination": "Sailfish.Contacts.ContactCardPostSavePage",
        "acceptDestinationAction": Silica.PageStackAction.Replace,
        "acceptDestinationProperties": savePageProperties,
    }
    pageStack.animatorPush("Sailfish.Contacts.ContactEditorDialog", editorProperties, pageStackOperationType)
}
