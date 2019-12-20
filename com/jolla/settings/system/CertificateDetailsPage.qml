/*
* Copyright (c) 2016 - 2019 Jolla Ltd.
* Copyright (c) 2019 Open Mobile Platform LLC.
*
* License: Proprietary
*/

import QtQuick 2.6
import Sailfish.Silica 1.0
import com.jolla.settings.system 1.0
import org.nemomobile.systemsettings 1.0

Page {
    id: root

    property var details
    property string website
    property int maxOctets: {
        var availableWidth = root.width - 2*Theme.horizontalPageMargin
        return Math.max(2, Math.min(10, Math.floor(availableWidth / octetMetrics.advanceWidth)))
    }

    function octetSequence(d) {
        return /^(?:[0-9a-f]{2}:)+(?:[0-9a-f]{2})$/i.test(d)
    }

    function formatOctetSequence(d) {
        var maxOctetsLength = maxOctets * 3
        for (var i = maxOctetsLength - 1; i < d.length; i += maxOctetsLength) {
            d = d.substr(0, i) + '\n' + d.substr(i+1)
        }
        return d
    }

    // Transform string from CamelCase to lower case with spaces
    // Leaves the capitalisation of the first letter unchanged
    function separateWordsWithSpaces(camelCaseString) {
        var parsed = camelCaseString.length > 0 ? camelCaseString[0].toUpperCase() : ""
        for (var pos = 1; pos < camelCaseString.length; pos++) {
            if (camelCaseString[pos].toUpperCase() === camelCaseString[pos]) {
                parsed += " "
            }
            parsed += camelCaseString[pos].toLowerCase()
        }
        return parsed
    }

    function translateKey(key) {
        var keyMapping = {
            //% "Business category"
            "businessCategory": qsTrId("settings_system-la-cert_business_category"),
            //% "Jurisdiction country name"
            "jurisdictionCountryName": qsTrId("settings_system-la-cert_jurisdiction_country_name"),
            //% "Jurisdiction state or province name"
            "jurisdictionStateOrProvinceName": qsTrId("settings_system-la-cert_jurisdiction_state_or_province_name"),
            //% "Serial number"
            "serialNumber": qsTrId("settings_system-la-cert_serial_number"),
            //% "Common name"
            "commonName": qsTrId("settings_system-la-cert_common_name"),
            //% "Country name"
            "countryName": qsTrId("settings_system-la-cert_country_name"),
            //% "Locality name"
            "localityName": qsTrId("settings_system-la-cert_locality_name"),
            //% "Organization name"
            "organizationName": qsTrId("settings_system-la-cert_organization_name"),
            //% "Organizational unit name"
            "organizationalUnitName": qsTrId("settings_system-la-cert_organizational_unit_name"),
            //% "State or province name"
            "stateOrProvinceName": qsTrId("settings_system-la-cert_state_or_province_name"),
            //: The certificate expiration date
            //% "Not after"
            "NotAfter": qsTrId("settings_system-la-cert_not_after"),
            //: The date the certificate becomes valid
            //% "Not before"
            "NotBefore": qsTrId("settings_system-la-cert_not_before"),
            //: The algorithm used by the certificate (e.g. RSA, elliptic curve)
            //% "Algorithm"
            "Algorithm": qsTrId("settings_system-la-cert_algorithm"),
            //: Refers to the size of the certificate's key in bits
            //% "Bits"
            "Bits": qsTrId("settings_system-la-cert_bits"),
            //: Refers to the exponent (power) used for the certificate's public key
            //: In the context of public-key cryptography and maths
            //% "Exponent"
            "Exponent": qsTrId("settings_system-la-cert_exponent"),
            //: Refers to the modulus (remainder) used for the certificate's public key
            //: In the context of public-key cryptography and maths
            //% "Modulus"
            "Modulus": qsTrId("settings_system-la-cert_modulus"),
            //: Refers to the certificate's public key
            //% "Public-Key"
            "Public-Key": qsTrId("settings_system-la-cert_public_key"),
            //: Refers to a hexadecimal representation of the certificate's public key
            //% "Data"
            "Data": qsTrId("settings_system-la-cert_data"),
            //: Abbreviation of Abstract Syntax Notation 1 Object Identifier
            //: No translation necessary
            //% "ASN.1 OID"
            "ASN1 OID": qsTrId("settings_system-la-cert_asn1_oid"),
            //% "Email address"
            "emailAddress": qsTrId("settings_system-la-cert_email_address"),
            //: NIST (National Instituate of Science and Technology) doesn't need translation
            //: Curve relates to the elliptic curve used for the public key cryptography
            //% "NIST curve"
            "NIST CURVE": qsTrId("settings_system-la-cert_nist_curve"),
            //: Shortening of Public Key, for a field showing the public key data
            //: No translation necessary
            //% "Pub"
            "pub": qsTrId("settings_system-la-cert_pub"),
        }

        if (keyMapping.hasOwnProperty(key)) {
            return keyMapping[key]
        } else {
            console.log("Missing translation for certificate key: " + key)
            return separateWordsWithSpaces(key)
        }
    }

    Component.onCompleted: {
        var addProperty = function(group, name, octetSequence, value) {
            properties.append({ 'group': group, 'name': name, 'octetSequence': octetSequence, 'value': value })
        }

        if (details['OrganizationName'] && details['OrganizationName'] !== "") {
            //% "Owner"
            addProperty("", qsTrId("settings_system-la-cert_owner"), false, details['OrganizationName'])
        }
        if (website !== "") {
            //% "Website"
            addProperty("", qsTrId("settings_system-la-cert_website"), false, website)
        }
        if (details['IssuerDisplayName'] && details['IssuerDisplayName'] !== "") {
            //% "Issuer"
            addProperty("", qsTrId("settings_system-la-cert_issuer"), false, details['IssuerDisplayName'])
        }
        //% "Version"
        addProperty("", qsTrId("settings_system-la-cert_version"), false, details['Version'])
        addProperty("", qsTrId("settings_system-la-cert_serial_number"), false, details['SerialNumber'])

        //% "Subject"
        var groupName = qsTrId("settings_system-he-subject")
        var group = details['Subject']
        var name
        for (name in group) {
            addProperty(groupName, translateKey(name), false, group[name])
        }

        //% "Validity"
        groupName = qsTrId("settings_system-he-validity")
        group = details['Validity']
        for (name in group) {
            var utcDate = new Date(group[name].getTime() + group[name].getTimezoneOffset() * 60000)
            addProperty(groupName, translateKey(name), false, Format.formatDate(utcDate, Format.TimePoint))
        }

        //% "Issuer"
        groupName = qsTrId("settings_system-he-issuer")
        group = details['Issuer']
        for (name in group) {
            addProperty(groupName, translateKey(name), false, group[name])
        }

        //% "Extensions"
        groupName = qsTrId("settings_system-he-extensions")
        group = details['Extensions']
        var os
        for (name in group) {
            os = octetSequence(group[name])
            // some might contain extra line breaks before and after
            addProperty(groupName, name, os, group[name].trim())
        }

        //% "Public Key"
        groupName = qsTrId("settings_system-he-public_key")
        group = details['SubjectPublicKeyInfo']

        for (name in group) {
            os = octetSequence(group[name])
            addProperty(groupName, translateKey(name), os, group[name])
        }

        //% "Signature"
        groupName = qsTrId("settings_system-he-signature")
        group = details['Signature']
        for (name in group) {
            os = octetSequence(group[name])
            addProperty(groupName, translateKey(name), os, group[name])
        }
    }

    TextMetrics {
        id: octetMetrics

        text: "FF:"
        font.family: 'Monospace'
        font.pixelSize: Theme.fontSizeSmall
    }

    ListModel {
        id: properties
    }

    SilicaListView {
        anchors.fill: parent

        header: PageHeader {
            //% "Certificate details"
            title: qsTrId("settings_system-he-certificate_details")
        }

        footer: Item {
            height: Theme.paddingLarge
        }

        model: properties

        section.property: 'group'
        section.criteria: ViewSection.FullString
        section.delegate: SectionHeader { text: section }

        delegate: DetailItem {
            label: model.name
            value: model.octetSequence ? formatOctetSequence(model.value) : model.value
            forceValueBelow: value.indexOf("\n") >= 0
            alignment: Qt.AlignLeft
            valueFont.family: model.octetSequence ? 'Monospace' : Theme.fontFamily
            valueFont.pixelSize: model.octetSequence ? Theme.fontSizeExtraSmall : Theme.fontSizeSmall
            // work around monospace being bolder than common font
            _valueItem.opacity: model.octetSequence ? 0.7 : 1.0
        }

        VerticalScrollDecorator {}
    }
}
