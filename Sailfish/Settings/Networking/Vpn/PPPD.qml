import QtQuick 2.0
import Sailfish.Silica 1.0
import org.nemomobile.systemsettings 1.0
import Sailfish.Settings.Networking.Vpn 1.0
import Sailfish.Settings.Networking 1.0

Column {
    function setProperties(providerProperties) {
        var getProperty = function(name) {
            if (providerProperties) {
                return providerProperties[name] || ''
            }
            return ''
        }

        var getBoolProperty = function(name) {
            if (getProperty(name) === 'true') {
                return true
            }
            return false
        }

        if (getBoolProperty('PPPD.ReqMPPE128')) {
            pppdReqMPPE.setValue('mppe128-required')
        } else if (getBoolProperty('PPPD.ReqMPPE40')) {
            pppdReqMPPE.setValue('mppe40-required')
        } else if (getBoolProperty('PPPD.ReqMPPE')) {
            pppdReqMPPE.setValue('mppe-required')
        } else {
            pppdReqMPPE.setValue('no-mppe')
        }
        pppdReqMPPEStateful.checked = getBoolProperty('PPPD.ReqMPPEStateful')
        pppdAcceptEAP.checked = !getBoolProperty('PPPD.RefuseEAP')
        pppdAcceptPAP.checked = !getBoolProperty('PPPD.RefusePAP')
        pppdAcceptCHAP.checked = !getBoolProperty('PPPD.RefuseCHAP')
        pppdAcceptMSCHAP.checked = !getBoolProperty('PPPD.RefuseMSCHAP')
        pppdAcceptMSCHAP2.checked = !getBoolProperty('PPPD.RefuseMSCHAP2')
        pppdAddrCtrlComp.checked = getBoolProperty('PPPD.UseAccomp')
        pppdBsdComp.checked = !getBoolProperty('PPPD.NoBSDComp')
        pppdProtocolComp.checked = !getBoolProperty('PPPD.NoPcomp')
        pppdDeflateComp.checked = !getBoolProperty('PPPD.NoDeflate')
        pppdVJComp.checked = !getBoolProperty('PPPD.NoVJ')
        pppdEchoInterval.text = getProperty('PPPD.EchoInterval')
        pppdEchoFailure.text = getProperty('PPPD.EchoFailure')
    }

    function updateProperties(providerProperties) {
        var updateProvider = function(name, value) {
            // If the value is empty/default, do not include the property in the configuration
            if (value != '' && value != '_default') {
                providerProperties[name] = value
            }
        }

        updateProvider('PPPD.ReqMPPE', pppdReqMPPE.currentIndex === 1 ? 'true' : 'false')
        updateProvider('PPPD.ReqMPPE40', pppdReqMPPE.currentIndex === 2 ? 'true' : 'false')
        updateProvider('PPPD.ReqMPPE128', pppdReqMPPE.currentIndex === 3 ? 'true' : 'false')
        updateProvider('PPPD.ReqMPPEStateful', pppdReqMPPEStateful.checked.toString())

        // These are reversed in meaning, if the value is checked, the option should be false
        updateProvider('PPPD.RefuseEAP', (!pppdAcceptEAP.checked).toString())
        updateProvider('PPPD.RefusePAP', (!pppdAcceptPAP.checked).toString())
        updateProvider('PPPD.RefuseCHAP', (!pppdAcceptCHAP.checked).toString())
        updateProvider('PPPD.RefuseMSCHAP', (!pppdAcceptMSCHAP.checked).toString())
        updateProvider('PPPD.RefuseMSCHAP2', (!pppdAcceptMSCHAP2.checked).toString())
        updateProvider('PPPD.NoBSDComp', (!pppdBsdComp.checked).toString())
        updateProvider('PPPD.NoPcomp', (!pppdProtocolComp.checked).toString())
        updateProvider('PPPD.NoDeflate', (!pppdDeflateComp.checked).toString())
        updateProvider('PPPD.NoVJ', (!pppdVJComp.checked).toString())

        updateProvider('PPPD.UseAccomp', pppdAddrCtrlComp.checked.toString())

        updateProvider('PPPD.EchoInterval', pppdEchoInterval.text)
        updateProvider('PPPD.EchoFailure', pppdEchoFailure.text)
    }

    function enableMSCHAP() {
        if (pppdReqMPPE.currentIndex === 0)
            return

        // If any of MPPE (Microsof Point to Point Encryption is used) either of MSCHAP must be enabled
        if (!pppdAcceptMSCHAP.checked && !pppdAcceptMSCHAP2.checked) {
            pppdAcceptMSCHAP.checked = true
            pppdAcceptMSCHAP2.checked = true
        }
    }

    width: parent.width

    SectionHeader {
        //: Options for the pppd utility program
        //% "PPP"
        text: qsTrId("settings_network-he-vpn_ppp_options")
    }

    ConfigComboBox {
        id: pppdReqMPPE

        values: [ 'no-mppe', 'mppe-required', 'mppe40-required', 'mppe128-required' ]

        //% "Authentication via MPPE"
        label: qsTrId("settings_network-la-vpn_pppd_reqmppe")
        onValueChanged: enableMSCHAP()
    }

    TextSwitch {
        id: pppdReqMPPEStateful

        //% "Allow stateful MPPE"
        text: qsTrId("settings_network-la-vpn_pppd_reqmppe_stateful")
    }

    SectionHeader {
        //% "Accept"
        text: qsTrId("settings_network-he-vpn_ppp_authentication_protocol_options")
    }

    TextSwitch {
        id: pppdAcceptEAP

        //% "EAP"
        text: qsTrId("settings_network-la-vpn_pppd_accept_eap")
    }

    TextSwitch {
        id: pppdAcceptPAP

        //% "PAP"
        text: qsTrId("settings_network-la-vpn_pppd_accept_pap")
    }

    TextSwitch {
        id: pppdAcceptCHAP

        //% "CHAP"
        text: qsTrId("settings_network-la-vpn_pppd_accept_chap")
    }

    TextSwitch {
        id: pppdAcceptMSCHAP

        //% "MSCHAP"
        text: qsTrId("settings_network-la-vpn_pppd_accept_mschap")
        onCheckedChanged: {
            // If any of the MPPE modes is selected and this is not checked, MSCHAP must be selected
            if (!checked && pppdReqMPPE.currentIndex !== 0 && !pppdAcceptMSCHAP2.checked)
                pppdAcceptMSCHAP2.checked = true
        }
    }

    TextSwitch {
        id: pppdAcceptMSCHAP2

        //% "MSCHAP v2"
        text: qsTrId("settings_network-la-vpn_pppd_accept_mschap2")
        onCheckedChanged: {
            // If any of the MPPE modes is selected and this is not checked, MSCHAPv2 must be selected
            if (!checked && pppdReqMPPE.currentIndex !== 0 && !pppdAcceptMSCHAP.checked)
                pppdAcceptMSCHAP.checked = true
        }
    }

    SectionHeader {
        //% "Compression"
        text: qsTrId("settings_network-he-vpn_ppp_compression_options")
    }

    TextSwitch {
        id: pppdBsdComp

        //% "BSD compression"
        text: qsTrId("settings_network-la-vpn_pppd_bsd_compression")
    }

    TextSwitch {
        id: pppdProtocolComp

        //% "Protocol compression"
        text: qsTrId("settings_network-la-vpn_pppd_protocol_compression")
    }

    TextSwitch {
        id: pppdDeflateComp

        //% "Deflate compression"
        text: qsTrId("settings_network-la-vpn_pppd_deflate_compression")
    }

    TextSwitch {
        id: pppdVJComp

        //% "Van Jacobson compression"
        text: qsTrId("settings_network-la-vpn_pppd_vj_compression")
    }

    TextSwitch {
        id: pppdAddrCtrlComp

        //% "Address/control compression"
        text: qsTrId("settings_network-la-vpn_pppd_ac_compression")
    }

    SectionHeader {
        //% "Echo"
        text: qsTrId("settings_network-he-vpn_ppp_echo_options")
    }

    ConfigTextField {
        id: pppdEchoInterval

        //% "Seconds between packets"
        label: qsTrId("settings_network-la-vpn_pppd_echo_interval")
        inputMethodHints: Qt.ImhDigitsOnly
        nextFocusItem: pppdEchoFailure
    }

    ConfigTextField {
        id: pppdEchoFailure

        //% "Fail after missed count"
        label: qsTrId("settings_network-la-vpn_pppd_echo_failure")
        inputMethodHints: Qt.ImhDigitsOnly
    }
}

